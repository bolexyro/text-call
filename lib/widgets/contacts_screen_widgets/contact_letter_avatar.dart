import 'package:flutter/material.dart';

class ContactLetterAvatar extends StatelessWidget {
  const ContactLetterAvatar({super.key, required this.contactName,});

  final String contactName;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple,
              Colors.blue,
            ],
          ),
        ),
        child: Text(
          contactName[0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
      ),
    );
  }
}
