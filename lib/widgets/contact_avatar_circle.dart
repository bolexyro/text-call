import 'package:flutter/material.dart';

class ContactAvatarCircle extends StatelessWidget {
  const ContactAvatarCircle({
    super.key,
    required this.avatarRadius,
  });

  final double avatarRadius;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: avatarRadius,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      child: const Icon(Icons.camera_alt),
    );
  }
}
