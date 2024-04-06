import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        body: GestureDetector(
          onLongPress: () {
            Clipboard.setData(
              ClipboardData(text: message),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied to clipboard'),
              ),
            );
          },
          child: SelectableText(
            message,
            style: const TextStyle(fontSize: 20.0),
          ),
        ));
  }
}
