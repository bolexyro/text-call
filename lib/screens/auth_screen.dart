import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final TextEditingController _textController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
        context,
      );

      _phoneAuthentication();
    }
  }

  void _anotherChance(String verificationId, int? resendToken) async {
    Map<String, dynamic>? smsCodeAndVerificationIdandResendToken =
        await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => OTPModalBottomSheet(
        phoneNumber: _enteredPhoneNumber,
        resendToken: resendToken,
        verificationId: verificationId,
      ),
      isDismissible: false,
      isScrollControlled: true,
    );

    if (smsCodeAndVerificationIdandResendToken != null) {
      try {
        final String verificationId =
            smsCodeAndVerificationIdandResendToken['verificationId']!;
        final String smsCode =
            smsCodeAndVerificationIdandResendToken['smsCode']!;
        // ignore: unused_local_variable
        final int? resendToken =
            smsCodeAndVerificationIdandResendToken['resendToken']!;

        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        await _auth.signInWithCredential(credential);
        await setPreferencesUpdateLocalAndRemoteDb(
            phoneNumber: _enteredPhoneNumber, ref: ref, context: context);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-verification-code') {
          showFlushBar(
            Colors.red,
            'The verification code from SMS/OTP is invalid. Please check and enter the correct verification code again.',
            FlushbarPosition.TOP,
            context,
            mainButtonOnPressed: () {
              _anotherChance(verificationId, resendToken);
            },
          );
        } else {
          showFlushBar(
            Colors.red,
            e.message ?? 'An Error occurred. Please Try again',
            FlushbarPosition.TOP,
            context,
          );
        }
        setState(() {
          _isAuthenticating = false;
        });
      }
    } else {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _phoneAuthentication() async {
    setState(() {
      _isAuthenticating = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: _enteredPhoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await setPreferencesUpdateLocalAndRemoteDb(
            phoneNumber: _enteredPhoneNumber, ref: ref, context: context);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {}

        showFlushBar(
          Colors.red,
          e.message ?? 'An Error occurred. Please Try again',
          FlushbarPosition.TOP,
          context,
        );

        setState(() {
          _isAuthenticating = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) async {
        _anotherChance(verificationId, resendToken);
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
        _flushbarShown = true;
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
                controller: _textController,
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      value.length != 10) {
                    return 'Your number should have 10 all digits';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.length == 1 && value == '0') {
                    _textController.text = '';
                  }
                },
                onSaved: (newValue) => _enteredPhoneNumber = newValue!,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: '',
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
