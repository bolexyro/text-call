import 'dart:io';

import 'package:flutter/material.dart';

class ImageDisplayer extends StatelessWidget {
  const ImageDisplayer({
    super.key,
    required this.imageFile,
    this.onDelete,
    required this.keyInMap,
    this.forPreview = false,
  });

  final File imageFile;
  final int keyInMap;
  final void Function(int key)? onDelete;
  final bool forPreview;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            decoration: BoxDecoration(border: Border.all(width: 2)),
            child: Image.file(imageFile),
          ),
        ),
        if (!forPreview)
          Positioned(
            right: -10,
            top: -10,
            child: GestureDetector(
              onTap: () => onDelete!(keyInMap),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 255, 57, 43),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
