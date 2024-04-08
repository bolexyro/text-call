import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/main.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/screens/otp_enter_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneNoController = TextEditingController();
  final Color _textAndButtonColor = const Color.fromARGB(255, 33, 52, 68);

  bool _isAuthenticating = false;
  @override
  void dispose() {
    _phoneNoController.dispose();
    super.dispose();
  }

  void _setPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserLoggedIn', true);
    await prefs.setString('phoneNumber', _phoneNoController.text);

    ref.read(contactsProvider.notifier).addContact(
          Contact(
            name: "Me",
            phoneNumber: _phoneNoController.text,
          ),
        );

    final db = FirebaseFirestore.instance;

    // Add a new document with a specified ID
    db.collection("users").doc(_phoneNoController.text).set(
      {'fcmToken': kToken},
    );
    setState(() {
      _isAuthenticating = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PhonePageScreen(),
      ),
    );
  }

  void _phoneAuthentication(String phoneNo) async {
    setState(() {
      _isAuthenticating = true;
    });
    final auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // ANDROID ONLY!

        // Sign the user in (or link) with the auto-generated credential
        await auth.signInWithCredential(credential);
        _setPreferences();
      },
      verificationFailed: (FirebaseAuthException e) {
        print('error message ${e.message}');
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        String? smsCode = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const OTPScreen()),
        );
        if (smsCode != null) {
          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);
          // Sign the user in (or link) with the credential
          await auth.signInWithCredential(credential);
          _setPreferences();
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'TEXT CALL',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 70,
                    color: _textAndButtonColor,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              displayFullTextOnTap: true,
              repeatForever: true,
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              keyboardType: TextInputType.phone,
              controller: _phoneNoController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                labelText: 'Phone No',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  _phoneAuthentication(_phoneNoController.text);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: _textAndButtonColor,
                  foregroundColor: Colors.white,
                ),
                child: _isAuthenticating == false
                    ? const Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
