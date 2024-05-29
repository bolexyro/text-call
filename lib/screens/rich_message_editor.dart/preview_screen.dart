import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/screens/rich_message_editor.dart/doc_displayer.dart';
import 'package:text_call/screens/rich_message_editor.dart/image_displayer.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_video_player.dart';
import 'package:text_call/screens/rich_message_editor.dart/wave_bubble.dart';
import 'package:text_call/utils/utils.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({
    super.key,
    required this.bolexyroJson,
    this.forExtremePreview = false,
  });

  final Map<int,Map<String, dynamic>> bolexyroJson;
  final bool forExtremePreview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        actions: forExtremePreview
            ? null
            : [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(bolexyroJson);
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/file-done.svg',
                    height: 30,
                  ),
                ),
              ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Column(
            children: [
              for (final indexMainMediaMapPair in bolexyroJson.entries)
                Column(
                  children: [
                    if (indexMainMediaMapPair.value.keys.first == 'document')
                      DocDisplayer(
                        backgroundColor:
                            deJsonifyColor(indexMainMediaMapPair.value['document']['backgroundColor']),
                        documentJson: indexMainMediaMapPair.value['document']['quillDocJson'],
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
      ),
    );
  }
}
