import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/utils/constants.dart';
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
  bool _changeOfPhoneNumberVerification = false;
  bool _shouldUpdateMeContact = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String? _originalPhoneNumber;

  late final Future<SharedPreferences> _prefs;

  GlobalKey? _flushBarKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.appOpenedFromPickedCall && !_flushbarShown) {
        showFlushBar(
            primaryFlushBarColor,
            'You have to login to see the message.',
            FlushbarPosition.TOP,
            context);
        _flushbarShown = true;
      }
    });

    _prefs = SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _validateForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _enteredPhoneNumber = '+234$_enteredPhoneNumber';
      FocusManager.instance.primaryFocus?.unfocus();

      final prefs = await _prefs;
      _originalPhoneNumber = prefs.getString('myPhoneNumber');
      if (_originalPhoneNumber != null &&
          _originalPhoneNumber != _enteredPhoneNumber) {
        _changeOfPhoneNumberVerification = true;
        _shouldUpdateMeContact = true;

        _flushBarKey = showFlushBar(
          const Color.fromARGB(255, 0, 63, 114),
          'Wrong number! To change from ${changeIntlToLocal(_originalPhoneNumber!)} to ${changeIntlToLocal(_enteredPhoneNumber)}, you have to verify both numbers.',
          FlushbarPosition.TOP,
          context,
          mainButton: ElevatedButton(
            onPressed: () async {
              (_flushBarKey!.currentWidget as Flushbar).dismiss();
              _flushBarKey = showFlushBar(
                primaryFlushBarColor,
                'NB: If you change your number, people with your previous number won\'t be able to text call you',
                FlushbarPosition.TOP,
                context,
                mainButton: ElevatedButton(
                  onPressed: () async {
                    (_flushBarKey!.currentWidget as Flushbar).dismiss();

                    _phoneAuthentication(phoneNumber: _originalPhoneNumber!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text('Ok'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text('Aight bet'),
          ),
        );

        return;
      }
      showFlushBar(
        const Color.fromARGB(255, 0, 63, 114),
        'You might be redirected to your browser. But don\'t panick. It is to verify you are not a bot...IKR',
        FlushbarPosition.TOP,
        context,
      );

      _phoneAuthentication(phoneNumber: _enteredPhoneNumber);
    }
  }

  void _otpHandler(
      String verificationId, int? resendToken, String phoneNumber) async {
    Map<String, dynamic>? smsCodeAndVerificationIdandResendToken =
        await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => OTPModalBottomSheet(
        phoneNumber: phoneNumber,
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
        if (_changeOfPhoneNumberVerification) {
          _phoneAuthentication(phoneNumber: _enteredPhoneNumber);
          _changeOfPhoneNumberVerification = false;
          return;
        }
        if (!_changeOfPhoneNumberVerification) {
          await setPreferencesUpdateLocalAndRemoteDb(
            newPhoneNumber: phoneNumber,
            ref: ref,
            context: context,
            shouldUpdateMeContact: _shouldUpdateMeContact,
            phoneNumberToBeUpdated: _originalPhoneNumber,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-verification-code') {
          _flushBarKey = showFlushBar(
            Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.error,
            'The verification code from SMS/OTP is invalid. Please check and enter the correct verification code again.',
            FlushbarPosition.TOP,
            context,
            mainButton: ElevatedButton(
              onPressed: () {
                (_flushBarKey!.currentWidget as Flushbar).dismiss();
                _otpHandler(verificationId, resendToken, phoneNumber);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white),
              child: const Text('Try again'),
            ),
          );
        } else {
          showFlushBar(
            Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.error,
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

  void _phoneAuthentication({required String phoneNumber}) async {
    setState(() {
      _isAuthenticating = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (!_changeOfPhoneNumberVerification) {
          await setPreferencesUpdateLocalAndRemoteDb(
            newPhoneNumber: _enteredPhoneNumber,
            ref: ref,
            context: context,
            shouldUpdateMeContact: _shouldUpdateMeContact,
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {}

        showFlushBar(
          Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.error,
          e.message ?? 'An Error occurred. Please Try again',
          FlushbarPosition.TOP,
          context,
        );

        setState(() {
          _isAuthenticating = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) async {
        _otpHandler(verificationId, resendToken, phoneNumber);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
      body: SafeArea(
        child: Padding(
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
                          'GET CODE',
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
      ),
    );
  }
}
