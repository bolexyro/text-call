import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class SentMessageScreen extends StatelessWidget {
  const SentMessageScreen({
    super.key,
    required this.message,
    required this.backgroundColor,
  });

  final String message;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('From your loved one or not hehe'),
        ),
        backgroundColor: backgroundColor,
        body: Center(
          child: AnimatedTextKit(
            animatedTexts: [
              TyperAnimatedText(
                message,
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
    );
  }
}
