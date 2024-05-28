import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:text_call/screens/rich_message_editor.dart/audio_recorder_card.dart';
import 'package:text_call/screens/rich_message_editor.dart/doc_displayer.dart';
import 'package:text_call/screens/rich_message_editor.dart/image_displayer.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_quill_editor.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_video_player.dart';
import 'package:text_call/screens/rich_message_editor.dart/wave_bubble.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({
    super.key,
    required this.displayedWidgetsMap,
    required this.controllersMap,
    required this.audioPathsMap,
    required this.imagePathsMap,
    required this.videoPathsMap,
    required this.quillEditorBackgroundColorMap,
  });

  final Map<int, Widget> displayedWidgetsMap;
  final Map<int, QuillController> controllersMap;
  final Map<int, String> audioPathsMap;
  final Map<int, String> imagePathsMap;
  final Map<int, String> videoPathsMap;
  final Map<int, Color> quillEditorBackgroundColorMap;

  @override
  Widget build(BuildContext context) {
    print(displayedWidgetsMap[3].runtimeType == ImageDisplayer);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Column(
            children: [
              for (final kvPair in displayedWidgetsMap.entries)
                Column(
                  children: [
                    if (kvPair.value.runtimeType == MyQuillEditor &&
                        controllersMap[kvPair.key]!
                                .document
                                .toDelta()
                                .toJson()[0]['insert'] !=
                            '\n')
                      DocDisplayer(
                        backgroundColor:
                            quillEditorBackgroundColorMap[kvPair.key] ??
                                Colors.white,
                        documentJson: jsonEncode(
                          controllersMap[kvPair.key]!
                              .document
                              .toDelta()
                              .toJson(),
                        ),
                      ),
                    if (kvPair.value.runtimeType == AudioRecorderCard &&
                        audioPathsMap[kvPair.key] != null)
                      WaveBubble(
                        audioPath: audioPathsMap[kvPair.key]!,
                      ),
                    if (kvPair.value.runtimeType == MyVideoPlayer)
                      MyVideoPlayer(
                        videoFile: File(videoPathsMap[kvPair.key]!),
                        keyInMap: kvPair.key,
                        forPreview: true,
                      ),
                    if (kvPair.value.runtimeType == ImageDisplayer)
                      ImageDisplayer(
                        imageFile: File(imagePathsMap[kvPair.key]!),
                        keyInMap: kvPair.key,
                        forPreview: true,
                      ),
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
