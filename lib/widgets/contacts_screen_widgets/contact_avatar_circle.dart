import 'dart:io';

import 'package:flutter/material.dart';

enum Purpose { selectingImage, displayingImage }

class ContactAvatarCircle extends StatelessWidget {
  const ContactAvatarCircle({
    super.key,
    required this.avatarRadius,
    required this.purpose,
    required this.imagePath,
    this.onCirclePressed,
  });

  final double avatarRadius;
  final Purpose purpose;
  final String? imagePath;
  final void Function()? onCirclePressed;

  @override
  Widget build(BuildContext context) {
    late final Widget activeContent;
    if (purpose == Purpose.selectingImage) {
      activeContent = InkWell(
        radius: avatarRadius,
        onTap: onCirclePressed,
        child: CircleAvatar(
          radius: avatarRadius,
          backgroundColor: imagePath == null ? Colors.blue : null,
          foregroundColor: Colors.white,
          backgroundImage:
              imagePath == null ? null : FileImage(File(imagePath!)),
          child: imagePath != null ? null : const Icon(Icons.camera_alt),
        ),
      );
    }

    if (purpose == Purpose.displayingImage) {
      activeContent = CircleAvatar(
        radius: avatarRadius,
        backgroundImage: FileImage(File(imagePath!)),
      );
    }

    return activeContent;
  }
}
