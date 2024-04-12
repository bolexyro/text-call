import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:google_fonts/google_fonts.dart';

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

  late Future _animationDelay;

  late WebSocketChannel _channel;

  bool _callSending = false;
  final _colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  @override
  void dispose() {
    _channel.sink.close();
    _confettiController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _callSomeone(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final callerPhoneNumber = prefs.getString('phoneNumber');
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://text-call-backend.onrender.com/ws/$callerPhoneNumber'),
    );
    setState(() {
      _callSending = true;
    });

    // the delay before we assume call was not picked
    _animationDelay = Future.delayed(
      const Duration(seconds: 30),
    );

    _channel.sink.add(
      json.encode(
        {
          'caller_phone_number': callerPhoneNumber,
          'callee_phone_number': widget.calleePhoneNumber,
          'message': _messageController.text,
        },
      ),
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
      messageWriterContent = StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
          } else {
            return FutureBuilder(
              future: _animationDelay,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Lottie.asset('assets/telephone_ringing_3d.json');
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            'Sorry Bro, Call Not Picked',
                            textAlign: TextAlign.center,
                            textStyle: GoogleFonts.pacifico(
                                fontSize: 32,
                                color: const Color.fromARGB(255, 139, 105, 2)),
                            speed: const Duration(milliseconds: 100),
                          ),
                        ],
                        displayFullTextOnTap: true,
                        repeatForever: false,
                        totalRepeatCount: 2,
                      ),
                      Lottie.asset('assets/sad_animation.json'),
                    ],
                  ),
                );
              },
            );
          }
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
