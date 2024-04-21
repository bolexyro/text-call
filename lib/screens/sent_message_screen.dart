import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:text_call/screens/phone_page_screen.dart';

// Bolexyro, make sure you handle the notifiaction controller stuff oo.
class SentMessageScreen extends StatefulWidget {
  const SentMessageScreen({
    super.key,

    required this.message,
    required this.backgroundColor,
    this.fromTerminated = false,
  });

  final String message;
  final Color backgroundColor;
  final bool fromTerminated;

  @override
  State<SentMessageScreen> createState() => _SentMessageScreenState();
}

class _SentMessageScreenState extends State<SentMessageScreen> {
  @override
  void initState() {
    // AwesomeNotifications().setListeners(
    //     onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    //     onNotificationCreatedMethod:
    //         NotificationController.onNotificationCreatedMethod,
    //     onNotificationDisplayedMethod:
    //         NotificationController.onNotificationDisplayedMethod,
    //     onDismissActionReceivedMethod:
    //         NotificationController.onDismissActionReceivedMethod);
    // _isUserLoggedIn = isUserLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('From your loved one or not hehe'),
        ),
        backgroundColor: widget.backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      widget.message,
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.white,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  displayFullTextOnTap: true,
                  repeatForever: false,
                  totalRepeatCount: 1,
                ),
              ),
            ),
            if (widget.fromTerminated)
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PhonePageScreen(),
                )),
                child: const Icon(Icons.home),
              ),
          ],
        ),
      ),
    );
  }
}
