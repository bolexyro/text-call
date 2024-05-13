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
    return LayoutBuilder(builder: (context, constraints) {
      return InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          onButtonPressed(buttonText);
        },
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
                fontSize: constraints.maxHeight * .43,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 255, 251, 251)
                    : Colors.black),
          ),
        ),
      );
    });
  }
}
