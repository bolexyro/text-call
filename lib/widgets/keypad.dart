import 'package:flutter/material.dart';
import 'package:text_call/widgets/keypad_button.dart';

class Keypad extends StatelessWidget {
  const Keypad({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeypadButton(buttonText: '1'),
            KeypadButton(buttonText: '2'),
            KeypadButton(buttonText: '3'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeypadButton(buttonText: '4'),
            KeypadButton(buttonText: '5'),
            KeypadButton(buttonText: '6'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeypadButton(buttonText: '7'),
            KeypadButton(buttonText: '8'),
            KeypadButton(buttonText: '9'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeypadButton(buttonText: '*'),
            KeypadButton(buttonText: '0'),
            KeypadButton(buttonText: '#'),
          ],
        )
      ],
    );
  }
}
