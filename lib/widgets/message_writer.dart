import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

class MessageWriter extends StatefulWidget {
  const MessageWriter({
    super.key,
    required this.calleePhoneNumber,
  });

  final String calleePhoneNumber;

  @override
  State<MessageWriter> createState() => _MessageWriterState();
}

class _MessageWriterState extends State<MessageWriter> {
  final TextEditingController _messageController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(milliseconds: 800),
  );

  late Future<http.Response> _response;
  late Future _animationDelay;

  bool _callSending = false;
  final _colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  @override
  void dispose() {
    _confettiController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _callSomeone(context) async {
    final url = Uri.https('text-call-backend.onrender.com', 'call-user/');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    setState(() {
      _callSending = true;
    });

    // this delay will never complete before the request is done because of the await attached to http.post
    // So, our animation will play for minimum 4 seconds and maximum the amount of time it takes the post
    // request to finish if it is greater than 4 seconds.
    _animationDelay = Future.delayed(
      const Duration(seconds: 4),
    );
    _response = http.post(
      url,
      body: json.encode(
        {
          'caller_phone_number': phoneNumber,
          'callee_phone_number': widget.calleePhoneNumber,
          'message': _messageController.text,
        },
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget messageWriterContent = Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            children: [
              TextField(
                // autofocus: true,
                controller: _messageController,
                minLines: 4,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    hintText: 'Enter the message you want to call them with',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Message',
                    labelStyle: const TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black,
                      ),
                    )),
              ),
              const SizedBox(
                height: 30,
              ),
              IconButton(
                onPressed: () => _callSomeone(context),
                icon: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.phone,
                    size: 35,
                  ),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (_callSending) {
      messageWriterContent = FutureBuilder(
        future: _animationDelay,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Lottie.asset('assets/telephone_ringing_3d.json');
          }

          return FutureBuilder(
            future: _response,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Lottie.asset('assets/telephone_ringing_3d.json');
              }

              if (snapshot.hasError) {
                return const Text('An Error Occurred');
              }
              if (snapshot.data!.statusCode == 200) {
                _confettiController.play();
                return AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'Call Sent Successfully',
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 80,
                        fontFamily: 'Horizon',
                      ),
                      colors: _colorizeColors,
                    )
                  ],
                  displayFullTextOnTap: true,
                  repeatForever: true,
                );
              }

              return const Text('Nothing much');
            },
          );
        },
      );
    }
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 207, 222, 234),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(40),
          ),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            messageWriterContent,
            ConfettiWidget(
              confettiController: _confettiController,
              shouldLoop: true,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              emissionFrequency: 0.1,
            ),
          ],
        ),
      ),
    );
  }
}
