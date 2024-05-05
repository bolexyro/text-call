import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/otp_modal_bottom_sheet.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({
    super.key,
    this.appOpenedFromPickedCall = false,
  });

  final bool appOpenedFromPickedCall;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late String _enteredPhoneNumber;
  bool _isAuthenticating = false;
  bool _flushbarShown = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> _setPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserLoggedIn', true);
    await prefs.setString('phoneNumber', _enteredPhoneNumber);

    ref.read(contactsProvider.notifier).addContact(
          Contact(
            name: "Me",
            phoneNumber: _enteredPhoneNumber,
            imagePath: null,
          ),
        );

    final db = FirebaseFirestore.instance;
    final fcm = FirebaseMessaging.instance;

    final fcmToken = await fcm.getToken();
    // Add a new document with a specified ID
    db.collection("users").doc(_enteredPhoneNumber).set(
      {'fcmToken': fcmToken},
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PhonePageScreen(),
      ),
    );
  }

  void _validateForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _enteredPhoneNumber = '+234$_enteredPhoneNumber';
      FocusManager.instance.primaryFocus?.unfocus();
      showFlushBar(
          const Color.fromARGB(255, 0, 63, 114),
          'You might be redirected to your browsser. But don\'t panick. It is to verify you are not a bot...IKR',
          FlushbarPosition.TOP,
          context);

      _phoneAuthentication();
    }
  }

  void _phoneAuthentication() async {
    setState(() {
      _isAuthenticating = true;
    });

    final auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: _enteredPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // ANDROID ONLY!

        // Sign the user in (or link) with the auto-generated credential
        await auth.signInWithCredential(credential);
        await _setPreferences();
      },
      verificationFailed: (FirebaseAuthException e) {
        // if (e.code == 'invalid-phone-number') {}
        showFlushBar(
          Colors.red,
          e.message ?? 'An Error occurred. Please Try again',
          FlushbarPosition.BOTTOM,
          context,
        );

        setState(() {
          _isAuthenticating = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) async {
        String? smsCode = await showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => const OTPModalBottomSheet(),
          isDismissible: false,
          isScrollControlled: true,
        );
        if (smsCode != null) {
          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: smsCode);
          // Sign the user in (or link) with the credential
          await auth.signInWithCredential(credential);
          await _setPreferences();
        }

        else {
          setState(() {
            _isAuthenticating = false;
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.appOpenedFromPickedCall && !_flushbarShown) {
        showFlushBar(Colors.blue, 'You have to login to see the message.',
            FlushbarPosition.TOP, context);
        _flushbarShown = true; // Set flag after showing flushbar
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color textAndButtonColor =
        Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context)
                .colorScheme
                .primary
                .withBlue(200)
                .withRed(50)
                .withGreen(120)
            : Theme.of(context).colorScheme.primary.withBlue(200);

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
                    fontSize: 55,
                    color: textAndButtonColor,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              displayFullTextOnTap: true,
              repeatForever: false,
              totalRepeatCount: 1,
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      value.length != 10) {
                    return 'Your number should have 10 all digits';
                  }
                  return null;
                },
                onSaved: (newValue) => _enteredPhoneNumber = newValue!,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  filled: Theme.of(context).brightness == Brightness.dark
                      ? null
                      : true,
                  labelText: 'Phone No',
                  prefixIcon: const Icon(Icons.call),
                  prefixText: '+234 - ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
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
                onPressed: _isAuthenticating == true
                    ? null
                    : () {
                        _validateForm();
                      },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: textAndButtonColor,
                  foregroundColor: Colors.white,
                ),
                child: _isAuthenticating == false
                    ? const Text(
                        'SEND CODE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : const CircularProgressIndicator(
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
