import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class SentMessageScreen extends StatelessWidget {
  const SentMessageScreen({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('From your loved one or not hehe'),
          ),
          backgroundColor: Colors.red,
          // body: GestureDetector(
          //   onLongPress: () {
          //     Clipboard.setData(
          //       ClipboardData(text: message),
          //     );
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('Copied to clipboard'),
          //       ),
          //     );
          //   },
          //   child: SelectableText(
          //     message,
          //     style: const TextStyle(fontSize: 20.0),
          //   ),
          // ),
          body: Center(
            child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    message,
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
              ),
          ),
          ),
    );
  }
}
