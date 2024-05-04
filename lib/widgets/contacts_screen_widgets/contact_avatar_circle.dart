import 'dart:io';

import 'package:flutter/material.dart';

class ContactAvatarCircle extends StatelessWidget {
  const ContactAvatarCircle({
    super.key,
    required this.avatarRadius,
    required this.imagePath,
    this.onCirclePressed,
  });

  final double avatarRadius;
  final String? imagePath;
  final void Function()? onCirclePressed;

  @override
  Widget build(BuildContext context) {
    late final Widget activeContent;
    if (onCirclePressed != null) {
      activeContent = InkWell(
        customBorder: const CircleBorder(), // radius: avatarRadius,
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
    } else {
      activeContent = CircleAvatar(
        radius: avatarRadius,
        backgroundColor: imagePath == null ? Colors.blue : null,
        foregroundColor: Colors.white,
        backgroundImage: imagePath == null ? null : FileImage(File(imagePath!)),
        child: imagePath != null ? null : const Icon(Icons.camera_alt),
      );
    }

    return activeContent;
  }
}
