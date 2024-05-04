import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:text_call/models/message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/choose_color_dialog.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageWriter extends ConsumerStatefulWidget {
  const MessageWriter({
    super.key,
    required this.calleePhoneNumber,
  });

  final String calleePhoneNumber;

  @override
  ConsumerState<MessageWriter> createState() => _MessageWriterState();
}

class _MessageWriterState extends ConsumerState<MessageWriter> {
  final TextEditingController _messageController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(milliseconds: 800),
  );

  late String recentId;

  late Future _animationDelay;
  Color _selectedColor = const Color.fromARGB(255, 13, 214, 214);

  WebSocketChannel? _channel;

  bool _callSending = false;
  final _colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  @override
  void dispose() {
    _channel?.sink.close();
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
      const Duration(seconds: 40),
    );

    recentId = DateTime.now().toString();
    // make sure to remove this line oo. it is only important for debugging purposes
    prefs.setString('recentId', recentId);
    _channel!.sink.add(
      json.encode(
        {
          'message_id': recentId,
          'caller_phone_number': callerPhoneNumber,
          'callee_phone_number': widget.calleePhoneNumber,
          'message': _messageController.text,
          'background_color': jsonifyColor(_selectedColor),
        },
      ),
    );
  }

  void _showColorPicker() async {
    FocusManager.instance.primaryFocus?.unfocus();

    Color? selectedColor = await showAdaptiveDialog(
      context: context,
      builder: (context) {
        return ChooseColorDialog(initialPickerColor: _selectedColor);
      },
    );

    if (selectedColor == null) {
      return;
    }
    setState(() {
      _selectedColor = selectedColor;
    });
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
                textCapitalization: TextCapitalization.sentences,
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
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).primaryColor,
                      child: InkWell(
                        onTap: _showColorPicker,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.color_lens,
                                  color: _selectedColor // Icon color
                                  ),
                              const SizedBox(width: 8),
                              Text(
                                'Selected Color',
                                style: TextStyle(
                                  color: _selectedColor, // Text color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              IconButton(
                onPressed: () async {
                  // if (await checkForInternetConnection(context)) {
                  _callSomeone(context);
                  // }
                },
                icon: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.phone,
                    size: 35,
                  ),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
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
        stream: _channel!.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snapshotData = json.decode(snapshot.data);
            if (snapshotData['call_status'] == 'rejected') {
              // create a recent in your table
              final recent = Recent.withoutContactObject(
                  category: RecentCategory.outgoingRejected,
                  message: Message(
                      message: _messageController.text,
                      backgroundColor: _selectedColor),
                  id: recentId,
                  phoneNumber: widget.calleePhoneNumber);

              ref.read(recentsProvider.notifier).addRecent(recent);
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          'Thy call hath been declined, leaving silence to linger in the void.',
                          textAlign: TextAlign.center,
                          textStyle: GoogleFonts.pacifico(
                              fontSize: 32,
                              color: const Color.fromARGB(255, 199, 32, 76)),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      displayFullTextOnTap: true,
                      repeatForever: false,
                      totalRepeatCount: 1,
                    ),
                    Lottie.asset('assets/animations/call_rejected.json',
                        height: 300),
                  ],
                ),
              );
            }
            final recent = Recent.withoutContactObject(
              category: RecentCategory.outgoingAccepted,
              message: Message(
                  message: _messageController.text,
                  backgroundColor: _selectedColor),
              id: recentId,
              phoneNumber: widget.calleePhoneNumber,
            );
            ref.read(recentsProvider.notifier).addRecent(recent);
            _confettiController.play();
            return AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Thy call hath been answered',
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
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
                  return Lottie.asset(
                      'assets/animations/telephone_ringing_3d.json');
                }
                final recent = Recent.withoutContactObject(
                    category: RecentCategory.outgoingUnanswered,
                    message: Message(
                        message: _messageController.text,
                        backgroundColor: _selectedColor),
                    id: recentId,
                    phoneNumber: widget.calleePhoneNumber);

                ref.read(recentsProvider.notifier).addRecent(recent);
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            'Alas, the call remained unanswered.',
                            textAlign: TextAlign.center,
                            textStyle: GoogleFonts.pacifico(
                                fontSize: 32,
                                color: const Color.fromARGB(255, 139, 105, 2)),
                            speed: const Duration(milliseconds: 100),
                          ),
                        ],
                        displayFullTextOnTap: true,
                        repeatForever: false,
                        totalRepeatCount: 1,
                      ),
                      Lottie.asset('assets/animations/call_missed.json'),
                    ],
                  ),
                );
              },
            );
          }
        },
      );
    }
    return Container(
      height: MediaQuery.sizeOf(context).height * .6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? makeColorLighter(Theme.of(context).primaryColor, 15)
            : const Color.fromARGB(255, 207, 222, 234),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SingleChildScrollView(child: messageWriterContent),
          ConfettiWidget(
            confettiController: _confettiController,
            shouldLoop: true,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            emissionFrequency: 0.1,
          ),
        ],
      ),
    );
  }
}
