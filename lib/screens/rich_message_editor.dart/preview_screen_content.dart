import 'dart:io';

import 'package:flutter/material.dart';
import 'package:text_call/screens/rich_message_editor.dart/doc_displayer.dart';
import 'package:text_call/screens/rich_message_editor.dart/image_displayer.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_video_player.dart';
import 'package:text_call/screens/rich_message_editor.dart/wave_bubble.dart';
import 'package:text_call/utils/utils.dart';

class PreviewScreenContent extends StatelessWidget {
  const PreviewScreenContent({
    super.key,
    required this.bolexyroJson,
  });

  final Map<int, Map<String, dynamic>> bolexyroJson;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          children: [
            for (final indexMainMediaMapPair in bolexyroJson.entries)
              Column(
                children: [
                  if (indexMainMediaMapPair.value.keys.first == 'document')
                    DocDisplayer(
                      backgroundColor: deJsonifyColorMapToColor(
                          indexMainMediaMapPair.value['document']
                              ['backgroundColor']),
                      documentJson: indexMainMediaMapPair.value['document']
                          ['quillDocJson'],
                    ),
                  if (indexMainMediaMapPair.value.keys.first == 'audio')
                    WaveBubble(
                      audioPath: indexMainMediaMapPair.value['audio'],
                    ),
                  if (indexMainMediaMapPair.value.keys.first == 'video')
                    MyVideoPlayer(
                      videoFile: File(indexMainMediaMapPair.value['video']),
                      forPreview: true,
                    ),
                  if (indexMainMediaMapPair.value.keys.first == 'image')
                    ImageDisplayer(
                      imageFile: File(indexMainMediaMapPair.value['image']),
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
    );
  }
}
