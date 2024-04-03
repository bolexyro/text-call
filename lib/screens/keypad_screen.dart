import 'package:flutter/material.dart';
import 'package:text_call/widgets/keypad.dart';

class KeypadScreen extends StatefulWidget {
  const KeypadScreen({super.key});

  @override
  State<KeypadScreen> createState() => _KeypadScreenState();
}

class _KeypadScreenState extends State<KeypadScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {},
              icon: const Badge(
                child: Icon(Icons.more_vert),
              ),
            )
          ],
        ),
        // TextField()
        const Spacer(),
        const Keypad(),
        const SizedBox(
          height: 20,
        ),
        IconButton(
          onPressed: () {},
          icon: const Padding(
            padding: EdgeInsets.all(5),
            child: Icon(
              Icons.phone,
              size: 35,
            ),
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
