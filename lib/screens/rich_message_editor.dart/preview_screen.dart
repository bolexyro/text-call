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
    required this.myOwnCustomDocumemntJson,
  });

  final Map<String, dynamic> myOwnCustomDocumemntJson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(myOwnCustomDocumemntJson);
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
              for (final kvPair in myOwnCustomDocumemntJson.entries)
                Column(
                  children: [
                    if (kvPair.key == 'document')
                      DocDisplayer(
                        backgroundColor:
                            deJsonifyColor(kvPair.value['backgroundColor']),
                        documentJson: kvPair.value['quillDocJson'],
                      ),
                    if (kvPair.key == 'audio')
                      WaveBubble(
                        audioPath: kvPair.value,
                      ),
                    if (kvPair.key == 'video')
                      MyVideoPlayer(
                        videoFile: File(kvPair.value),
                        forPreview: true,
                      ),
                    if (kvPair.key == 'image')
                      ImageDisplayer(
                        imageFile: File(kvPair.value),
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
