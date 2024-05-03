import 'dart:io';

import 'package:flutter/material.dart';

enum Purpose { selectingImage, displayingImage }

class ContactAvatarCircle extends StatelessWidget {
  const ContactAvatarCircle({
    super.key,
    required this.avatarRadius,
    required this.purpose,
    required this.imagePath,
  });

  final double avatarRadius;
  final Purpose purpose;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    late final Widget activeContent;
    if (purpose == Purpose.selectingImage) {
      activeContent = InkWell(
        radius: avatarRadius,
        onTap: () {},
        child: CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: const Icon(Icons.camera_alt),
        ),
      );
    }

    if (purpose == Purpose.displayingImage) {
      if (imagePath == null) {
        activeContent = InkWell(
          radius: avatarRadius,
          onTap: () {},
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.camera_alt),
          ),
        );
      } else {
        activeContent = CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: Image.file(
            File(imagePath!),
          ),
        );
      }
    }
    return activeContent;
  }
}
