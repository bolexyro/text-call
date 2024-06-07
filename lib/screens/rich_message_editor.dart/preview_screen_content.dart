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

  final Map<String, dynamic> bolexyroJson;

  @override
  Widget build(BuildContext context) {
    // since the user cannot really choose which medias in a message to keep available offline and so when they
    // save a message offline, the audio, video, image would be made available offline.
    // so we can say if the localPath of maybe the audio is not null, then the message is available offline.
    bool isAvailableOffline = false;
    for (final indexMainMediaMapPair in bolexyroJson.entries) {
      // Skip 'document' entries
      if (indexMainMediaMapPair.value.keys.first != 'document') {
        // Get the media map (audio, video, image)
        final mediaMap = indexMainMediaMapPair.value.values.first;

        // Iterate through media map entries
        for (final mediaEntry in mediaMap.entries) {
          // Check if the 'local' path is not null
          if (mediaEntry.value['local'] != null) {
            isAvailableOffline = true;
            break;
          }
        }
      }
      if (isAvailableOffline) {
        break;
      } // Exit the loop early if already determined to be available offline
    }
    print(isAvailableOffline);
    print(bolexyroJson);

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
                      audioPath: indexMainMediaMapPair.value['audio']
                              ['audioPaths']['local'] ??
                          indexMainMediaMapPair.value['audio']['audioPaths']
                              ['online'],
                    ),
                  if (indexMainMediaMapPair.value.keys.first == 'video')
                    MyVideoPlayer(
                      videoPath: indexMainMediaMapPair.value['video']
                              ['videoPaths']['local'] ??
                          indexMainMediaMapPair.value['video']['videoPaths']
                              ['online'],
                      forPreview: true,
                      isNetworkVideo: !isAvailableOffline,
                    ),
                  if (indexMainMediaMapPair.value.keys.first == 'image')
                    ImageDisplayer(
                      imagePath: indexMainMediaMapPair.value['image']
                              ['imagePaths']['local'] ??
                          indexMainMediaMapPair.value['image']['imagePaths']
                              ['online'],
                      forPreview: true,
                      isNetworkImage: !isAvailableOffline,
                    ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
