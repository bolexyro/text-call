import 'dart:async';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:text_call/utils/utils.dart';

class OTPModalBottomSheet extends StatefulWidget {
  const OTPModalBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.resendToken,
  });

  final String phoneNumber;
  final int? resendToken;

  @override
  State<OTPModalBottomSheet> createState() => _OTPModalBottomSheetState();
}

class _OTPModalBottomSheetState extends State<OTPModalBottomSheet> {
  List<FocusNode> focusNodes = [];
  List<TextEditingController> textControllers = [];
  int counter = 40;
  String counterText = '';
  bool resendAvailable = false;

  void startCountDownTimer() {
    Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (counter == 0) {
          timer.cancel();
          setState(() {
            resendAvailable = true;
          });
        } else {
          setState(() {
            counter--;
            counterText = counter.toString().length == 2
                ? counter.toString()
                : '0$counter';
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      focusNodes.add(FocusNode());
      textControllers.add(TextEditingController(text: '\u200B'));
    }
    startCountDownTimer();
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    for (final controller in textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String removeEmptyCharacters(String otpWEmptyCh) {
    return otpWEmptyCh[1] +
        otpWEmptyCh[3] +
        otpWEmptyCh[5] +
        otpWEmptyCh[7] +
        otpWEmptyCh[9] +
        otpWEmptyCh[11];
  }

  String getOTP() {
    String output = '';
    for (final controller in textControllers) {
      output += controller.text;
    }
    return output;
  }

  void resendOtp(int resendToken) async {
    final auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      codeAutoRetrievalTimeout: (verificationId) {
        
      },
        forceResendingToken: resendToken,
        phoneNumber: widget.phoneNumber,
        codeSent:  (String verificationId, int? resendToken){},
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
        
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).vertical == 0
                    ? 200
                    : MediaQuery.viewInsetsOf(context).vertical + 30),
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 110,
                  ),
                  const Text(
                    'Enter the Code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                    ),
                  ),
                  Text(
                    'Enter the 6 digit code sent to you at ${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int index = 0; index < 6; index++)
                        Row(
                          children: [
                            SizedBox(
                              width: 43,
                              child: TextFormField(
                                autofocus: index == 0 ? true : false,
                                controller: textControllers[index],
                                focusNode: focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                onChanged: (value) {
                                  // print(
                                  //     'value is $value value length is ${value.length}');

                                  if (value.length >= 2 && index < 5) {
                                    textControllers[index].text =
                                        value.length == 2
                                            ? '${value[0]}${value[1]}'
                                            : '${value[0]}${value[2]}';
                                    // print(
                                    //     'text controlle text is ${textControllers[index].text.length}');
                                    if (textControllers[index + 1]
                                        .text
                                        .isEmpty) {
                                      textControllers[index + 1].text =
                                          '\u200B';
                                    }
                                    FocusScope.of(context).nextFocus();
                                  }

                                  if (value.isEmpty && index > 0) {
                                    FocusScope.of(context)
                                        .requestFocus(focusNodes[index - 1]);
                                  }

                                  if (value.length == 1 &&
                                      index == 0 &&
                                      value != '\u200B') {
                                    textControllers[index + 1].text = '\u200B';
                                    textControllers[index].text =
                                        '\u2008$value';

                                    FocusScope.of(context).nextFocus();
                                  }
                                  if (getOTP().length == 12) {
                                    Navigator.of(context)
                                        .pop(removeEmptyCharacters(getOTP()));
                                  }
                                },

                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                  ),
                                  counterText: '',
                                ),
                                // maxLength: 2,
                              ),
                            ),
                            if (index != 5)
                              const SizedBox(
                                width: 10,
                              )
                          ],
                        )
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (counter == 0)
                    TextButton(
                      onPressed: () {},
                      child: const Text('Resend Code'),
                    ),
                  if (counter != 0)
                    Text('Resend code would be availlbe in $counterText'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
