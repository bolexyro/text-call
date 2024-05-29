import 'dart:convert';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:text_call/models/message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/rich_message_editor.dart/confirm_discard_dialog.dart';
import 'package:text_call/screens/rich_message_editor.dart/preview_screen.dart';
import 'package:text_call/screens/rich_message_editor.dart/rich_message_editor_screen.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/dialogs/choose_color_dialog.dart';
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

  late String _recentId;
  late Future _animationDelay;
  WebSocketChannel? _channel;
  bool _callSending = false;
  Color _selectedColor = const Color.fromARGB(255, 13, 214, 214);
  final _colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  late Widget messageWriterMessageBox;

  @override
  void initState() {
    messageWriterMessageBox = TextField(
      controller: _messageController,
      minLines: 4,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Enter the message you want to call them with',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelText: 'Message',
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _confettiController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _callSomeone(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final callerPhoneNumber = prefs.getString('myPhoneNumber');
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://text-call-backend.onrender.com/ws/$callerPhoneNumber'),
    );
    setState(() {
      _callSending = true;
    });

    // the delay before we assume call was not picked
    _animationDelay = Future.delayed(
      const Duration(seconds: 60),
    );

    _recentId = DateTime.now().toString();
    // make sure to remove this line oo. it is only important for debugging purposes
    prefs.setString('recentId', _recentId);
    _channel!.sink.add(
      json.encode(
        {
          'message_id': _recentId,
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

  void _updateMyOwnDocumentJson(
      Map<int, Map<String, dynamic>> newBolexyroJson) {
    setState(() {
      messageWriterMessageBox = FileUiPlaceHolder(
        onBolexroJsonUpdated: _updateMyOwnDocumentJson,
        onDelete: _resetMessageWriterMessageBox,
        bolexyroJson: newBolexyroJson,
      );
    });
  }

  void _resetMessageWriterMessageBox() {
    setState(() {
      messageWriterMessageBox = TextField(
        controller: _messageController,
        minLines: 4,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Enter the message you want to call them with',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          labelText: 'Message',
        ),
      );
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
              messageWriterMessageBox,
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _showColorPicker,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
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
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final Map<int, Map<String, dynamic>>?
                          myOwnCustomDocumemntJson =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RichMessageEditorScreen(),
                        ),
                      );

                      if (myOwnCustomDocumemntJson != null) {
                        _updateMyOwnDocumentJson(myOwnCustomDocumemntJson);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/editor.svg',
                          height: kIconHeight,
                          colorFilter:
                              ColorFilter.mode(_selectedColor, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Complex Editor?',
                          style: TextStyle(
                            color: _selectedColor, // Text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
            if (snapshotData['call_status'] == 'error') {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: .5,
                      child: Lottie.asset(
                        'assets/animations/404 user not found.json',
                        height: 300,
                      ),
                    ),
                    Text(
                      'The number you are trying to call doesn\'t exist. Are you sure you are not trying to call a previos version of your number.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pacifico(
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshotData['call_status'] == 'rejected') {
              // create a recent in your table
              final recent = Recent.withoutContactObject(
                category: RecentCategory.outgoingRejected,
                message: Message(
                  message: _messageController.text,
                  backgroundColor: _selectedColor,
                ),
                id: _recentId,
                phoneNumber: widget.calleePhoneNumber,
                callTime: DateTime.parse(_recentId),
              );

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
            if (snapshotData['call_status'] == 'accepted') {
              final recent = Recent.withoutContactObject(
                category: RecentCategory.outgoingAccepted,
                message: Message(
                    message: _messageController.text,
                    backgroundColor: _selectedColor),
                id: _recentId,
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
            }
            if (snapshotData['call_status'] == 'callee_busy') {
              Future.delayed(const Duration(seconds: 3), () {
                setState(() {
                  _callSending = false;
                });
              });
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          'The number you are calling is receiving another call rn. Try again in less than 20 seconds',
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
            }
            return const Text(
                'This should be for some case that is not available yet');
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
                  id: _recentId,
                  phoneNumber: widget.calleePhoneNumber,
                );

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
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height * .6,
            ),
            child: Container(
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
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          0, 0, 0, MediaQuery.viewInsetsOf(context).vertical),
                      child: SingleChildScrollView(child: messageWriterContent),
                    ),
                  ),
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
          ),
        ),
      ],
    );
  }
}

class FileUiPlaceHolder extends StatelessWidget {
  const FileUiPlaceHolder({
    super.key,
    required this.bolexyroJson,
    required this.onDelete,
    required this.onBolexroJsonUpdated,
  });
  final Map<int, Map<String, dynamic>> bolexyroJson;
  final void Function() onDelete;
  final void Function(Map<int, Map<String, dynamic>> newBolexyroJson)
      onBolexroJsonUpdated;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewScreen(
            bolexyroJson: bolexyroJson,
            forExtremePreview: true,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? makeColorLighter(Theme.of(context).primaryColor, 20)
              : const Color.fromARGB(255, 176, 208, 235),
        ),
        child: Center(
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              SvgPicture.asset(
                'assets/icons/regular-file.svg',
                height: 40,
              ),
              const SizedBox(
                width: 20,
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Complex_Message.txtcall',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Click to view')
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  IconButton(
                    onPressed: () async {
                      final Map<int, Map<String, dynamic>>? newBolexyroJson =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RichMessageEditorScreen(
                            bolexyroJSon: bolexyroJson,
                          ),
                        ),
                      );

                      if (newBolexyroJson != null) {
                        onBolexroJsonUpdated(newBolexyroJson);
                      }
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () async {
                      final bool? toDiscard = await showAdaptiveDialog(
                        context: context,
                        builder: (context) => const ConfirmDiscardDialog(),
                      );
                      if (toDiscard == true) {
                        onDelete();
                      }
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
              const SizedBox(
                width: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
