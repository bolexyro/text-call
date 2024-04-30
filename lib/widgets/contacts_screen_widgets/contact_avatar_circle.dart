import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
      child: IconButton(
        icon: const Icon(Icons.camera_alt),
        onPressed: () async {
          final ImagePicker picker = ImagePicker();
          // final XFile? image =
final XFile? file = await picker.pickImage(source: ImageSource.gallery);
        },
      ),
    );
  }
}
