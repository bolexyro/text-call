import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            decoration: BoxDecoration(border: Border.all(width: 2)),
            child: networkImage
                ? Image.network(imagePath)
                : Image.file(File(imagePath)),
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
      ],
    );
  }
}
