import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/utils/constants.dart';

class ImageDisplayer extends StatelessWidget {
  // if not for preview, keyInMp and onDelete should be non null
  const ImageDisplayer({
    super.key,
    required this.imagePath,
    this.onDelete,
    this.keyInMap,
    this.forPreview = false,
    required this.networkImage,
  });

  final String imagePath;
  final int? keyInMap;
  final void Function(int key)? onDelete;
  final bool forPreview;
  final bool networkImage;

  void _goFullScreen(BuildContext context, Widget imageWidget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GestureDetector(
          onDoubleTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: Center(
                  child: Hero(
                    tag: imagePath,
                    child: imageWidget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = networkImage
        ? CachedNetworkImage(
            imageUrl: imagePath,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
              child:
                  CircularProgressIndicator(value: downloadProgress.progress),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.contain,
          )
        : Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          );
    return SizedBox(
      height: 400,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: kSpaceBtwWidgetsInPreviewOrRichTextEditor),
            child: GestureDetector(
              onDoubleTap: () {
                _goFullScreen(context, imageWidget);
              },
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(width: 2),
                ),
                child: Center(
                  child: Hero(
                    tag: imagePath,
                    child: imageWidget,
                  ),
                ),
              ),
            ),
          ),
          if (!forPreview)
            Positioned(
              right: -10,
              top: -10,
              child: GestureDetector(
                onTap: () => onDelete!(keyInMap!),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/delete.svg',
                    colorFilter: const ColorFilter.mode(
                      Color.fromARGB(255, 255, 57, 43),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 10,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                _goFullScreen(context, imageWidget);
              },
              child: SvgPicture.asset(
                'assets/icons/full-screen.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                height: kIconHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
