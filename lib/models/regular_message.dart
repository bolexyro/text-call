import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:text_call/utils/utils.dart';

enum MessageType { regular, complex }

class RegularMessage {
  const RegularMessage({
    required this.messageString,
    required this.backgroundColor,
  });

  final String messageString;
  final Color backgroundColor;

  factory RegularMessage.fromJsonString(String messageJsonString) {
    final messageJson = jsonDecode(messageJsonString);
    return RegularMessage(
      messageString: messageJson['messageString'],
      backgroundColor: deJsonifyColorMapToColor(
        messageJson['backgroundColor'],
      ),
    );
  }

  String get toJsonString => jsonEncode(
        {
          'messageString': messageString,
          'backgroundColor': jsonifyColor(backgroundColor),
        },
      );
}
