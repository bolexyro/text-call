import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KeypadButton extends ConsumerWidget {
  const KeypadButton({
    super.key,
    required this.buttonText,
    required this.onButtonPressed,
  });

  final String buttonText;
  final void Function(String digit) onButtonPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextButton(
        // style: ButtonStyle(fixedSize: MaterialStateProperty.all(Size(70, 70))),
        onPressed: () {
          onButtonPressed(buttonText);
        },
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
