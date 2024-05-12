import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/utils/utils.dart';

class OTPModalBottomSheet extends ConsumerStatefulWidget {
  const OTPModalBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.resendToken,
    required this.verificationId,
  });

  final String phoneNumber;
  final int? resendToken;
  final String verificationId;

  @override
  ConsumerState<OTPModalBottomSheet> createState() =>
      _OTPModalBottomSheetState();
}

class _OTPModalBottomSheetState extends ConsumerState<OTPModalBottomSheet> {
  final List<FocusNode> _focusNodes = [];
  final List<TextEditingController> _textControllers = [];
  final int _totalCounterSeconds = 40;
  late int _counter;
  String _counterText = '';
  late String _phoneNumber;
  bool _codeResent = false;
  late int? _resendToken;

  @override
  void initState() {
    super.initState();
    _counter = _totalCounterSeconds;
    _resendToken = widget.resendToken;
    _phoneNumber = widget.phoneNumber;

    for (int i = 0; i < 6; i++) {
      _focusNodes.add(FocusNode());
      _textControllers.add(TextEditingController(text: '\u200B'));
    }
    startCountDownTimer();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void startCountDownTimer() {
    Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_counter == 0) {
          timer.cancel();
        } else {
          setState(() {
            _counter--;
            _counterText = _counter.toString().length == 2
                ? _counter.toString()
                : '0$_counter';
          });
        }
      },
    );
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
    for (final controller in _textControllers) {
      output += controller.text;
    }
    return output;
  }

  late Completer<String> _completer;

  Future<String> otpOnResend() {
    _completer = Completer<String>();
    return _completer.future;
  }

  void resendOtp() async {
    _codeResent = true;
    final auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      forceResendingToken: _resendToken,
      phoneNumber: _phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // await setPreferencesUpdateLocalAndRemoteDb(
        //     phoneNumber: _enteredPhoneNumber, ref: ref, context: context);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) async {
        _resendToken = resendToken;
        String smsCode = await otpOnResend();
        Navigator.of(context).pop({
          'smsCode': smsCode,
          'verificationId': verificationId,
          'resendToken': _resendToken
        });
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
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
                    height: 15,
                  ),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(
                    height: 60,
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
                    'Enter the 6 digit code sent to you at ${changeIntlToLocal(_phoneNumber)}',
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
                                controller: _textControllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                onChanged: (value) {
                                  // print(
                                  //     'value is $value value length is ${value.length}');

                                  if (value.length >= 2 && index < 5) {
                                    _textControllers[index].text =
                                        value.length == 2
                                            ? '${value[0]}${value[1]}'
                                            : '${value[0]}${value[2]}';
                                    // print(
                                    //     'text controlle text is ${textControllers[index].text.length}');
                                    if (_textControllers[index + 1]
                                        .text
                                        .isEmpty) {
                                      _textControllers[index + 1].text =
                                          '\u200B';
                                    }
                                    FocusScope.of(context).nextFocus();
                                  }

                                  if (value.isEmpty && index > 0) {
                                    FocusScope.of(context)
                                        .requestFocus(_focusNodes[index - 1]);
                                  }

                                  if (value.length == 1 &&
                                      index == 0 &&
                                      value != '\u200B') {
                                    _textControllers[index + 1].text = '\u200B';
                                    _textControllers[index].text =
                                        '\u2008$value';

                                    FocusScope.of(context).nextFocus();
                                  }
                                  if (getOTP().length == 12) {
                                    // I am doing this just in case firebase sends a different oTP in the new ss
                                    if (!_codeResent) {
                                      // here we weould be sending the same verificationId and resendToken as the one in widget.<whatever>
                                      Navigator.of(context).pop({
                                        'smsCode':
                                            removeEmptyCharacters(getOTP()),
                                        'verificationId': widget.verificationId,
                                        'resendToken': _resendToken,
                                      });
                                    } else {
                                      _completer.complete(
                                        removeEmptyCharacters(getOTP()),
                                      );
                                    }
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
                  if (_counter == 0)
                    TextButton(
                      onPressed: () {
                        resendOtp();
                        setState(() {
                          _counter = _totalCounterSeconds;
                        });
                        startCountDownTimer();
                      },
                      child: const Text('Resend Code'),
                    ),
                  if (_counter != 0)
                    Text('Resend code would be available in $_counterText'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
