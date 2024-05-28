import 'dart:io';

import 'package:flutter/material.dart';

class ImageDisplayer extends StatelessWidget {
  const ImageDisplayer({
    super.key,
    required this.imageFile,
    required this.onDelete,
    required this.keyInMap,
  });

  final File imageFile;
  final int keyInMap;
  final void Function(int key) onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.file(imageFile),
        Positioned(
          right: -10,
          top: -10,
          child: GestureDetector(
            onTap: () => onDelete(keyInMap),
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
