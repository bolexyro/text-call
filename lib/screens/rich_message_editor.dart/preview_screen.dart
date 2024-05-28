import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:text_call/screens/rich_message_editor.dart/audio_recorder_card.dart';
import 'package:text_call/screens/rich_message_editor.dart/doc_displayer.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_quill_editor.dart';
import 'package:text_call/screens/rich_message_editor.dart/wave_bubble.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({
    super.key,
    required this.displayedWidgetsMap,
    required this.controllersMap,
    required this.audioPathsMap,
  });

  final Map<int, Widget> displayedWidgetsMap;
  final Map<int, QuillController> controllersMap;
  final Map<int, String> audioPathsMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              for (final kvPair in displayedWidgetsMap.entries)
                Column(
                  children: [
                    if (kvPair.value.runtimeType == MyQuillEditor)
                      DocDisplayer(
                        documentJson: jsonEncode(
                          controllersMap[kvPair.key]!.document.toDelta().toJson(),
                        ),
                      )
                    else if (kvPair.value.runtimeType == AudioRecorderCard)
                      WaveBubble(
                        audioPath: audioPathsMap[kvPair.key]!,
                      )
                    else
                      kvPair.value,
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
