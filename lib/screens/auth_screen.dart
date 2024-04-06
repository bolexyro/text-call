import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:text_call/main.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/screens/otp_enter_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneNoController = TextEditingController();

  @override
  void dispose() {
    _phoneNoController.dispose();
    super.dispose();
  }

  void _phoneAuthentication(String phoneNo) async {
    final auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // ANDROID ONLY!

        // Sign the user in (or link) with the auto-generated credential
        await auth.signInWithCredential(credential);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TextCall(),
          ),
        );
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
          print(smsCode);
          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);
          // Sign the user in (or link) with the credential
          await auth.signInWithCredential(credential);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PhonePageScreen(),
            ),
          );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Get on Board',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const Text('Create your profile to start your journey.'),
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
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
