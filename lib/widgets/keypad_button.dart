import 'package:flutter/material.dart';

class KeypadButton extends StatelessWidget {
  const KeypadButton({
    super.key,
    required this.buttonText,
  });

  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextButton(
        // style: ButtonStyle(fixedSize: MaterialStateProperty.all(Size(70, 70))),
        onPressed: () {},
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
