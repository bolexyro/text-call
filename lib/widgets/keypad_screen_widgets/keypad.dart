import 'package:flutter/material.dart';
import 'package:text_call/widgets/keypad_screen_widgets/keypad_button.dart';

class Keypad extends StatelessWidget {
  const Keypad({
    super.key,
    required this.onButtonPressed,
  });

  final void Function(String didit) onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeypadButton(
              buttonText: '1',
              onButtonPressed: onButtonPressed,
            ),
            KeypadButton(
              buttonText: '2',
              onButtonPressed: onButtonPressed,
            ),
            KeypadButton(
              buttonText: '3',
              onButtonPressed: onButtonPressed,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeypadButton(
              buttonText: '4',
              onButtonPressed: onButtonPressed,
            ),
            KeypadButton(
              buttonText: '5',
              onButtonPressed: onButtonPressed,
            ),
            KeypadButton(
              buttonText: '6',
              onButtonPressed: onButtonPressed,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeypadButton(
              buttonText: '7',
              onButtonPressed: onButtonPressed,
            ),
            KeypadButton(
              buttonText: '8',
              onButtonPressed: onButtonPressed,
            ),
            KeypadButton(
              buttonText: '9',
              onButtonPressed: onButtonPressed,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeypadButton(
              buttonText: '+',
              onButtonPressed: onButtonPressed,
            ),
            KeypadButton(
              buttonText: '0',
              onButtonPressed: onButtonPressed,
            ),
            KeypadButton(
              buttonText: '#',
              onButtonPressed: onButtonPressed,
            ),
          ],
        )
      ],
    );
  }
}
