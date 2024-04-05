import 'package:flutter/material.dart';

class SentMessageScreen extends StatelessWidget {
  const SentMessageScreen({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('From your loved one or not hehe'),
      ),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
