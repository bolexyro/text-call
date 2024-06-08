import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/screens/rich_message_editor.dart/preview_screen_content.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({
    super.key,
    required this.bolexyroJson,
    this.forExtremePreview = false,
    this.showPreviewText = true,
  });

  final Map<String, dynamic> bolexyroJson;
  final bool forExtremePreview;
  final bool showPreviewText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: showPreviewText ? const Text('PREVIEW') : null,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        actions: [
          
          if (!forExtremePreview)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (bolexyroJson.isNotEmpty) {
                  Navigator.of(context).pop(bolexyroJson);
                }
              },
              icon: SvgPicture.asset(
                'assets/icons/file-done.svg',
                height: 30,
              ),
            ),
        ],
      ),
      body: PreviewScreenContent(
        bolexyroJson: bolexyroJson,
      ),
    );
  }
}
