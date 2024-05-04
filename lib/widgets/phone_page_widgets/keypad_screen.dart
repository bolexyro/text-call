import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/widgets/keypad_screen_widgets/keypad.dart';
import 'package:text_call/widgets/keypad_screen_widgets/logout_menu_anchor.dart';

class KeypadScreen extends ConsumerStatefulWidget {
  const KeypadScreen({super.key});

  @override
  ConsumerState<KeypadScreen> createState() => _KeypadScreenState();
}

class _KeypadScreenState extends ConsumerState<KeypadScreen> {
  final _inputedDigitsTextController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _inputedDigitsTextController.dispose();
    super.dispose();
  }

  void _addDigit(String myText) {
    final text = _inputedDigitsTextController.text;
    final textSelection = _inputedDigitsTextController.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    setState(() {
      _inputedDigitsTextController.text = newText;
      _inputedDigitsTextController.selection = textSelection.copyWith(
        baseOffset: textSelection.start + myTextLength,
        extentOffset: textSelection.start + myTextLength,
      );
    });
  }

  void _backspace({bool? longPress}) {
    if (longPress == true) {
      setState(() {
        _inputedDigitsTextController.text = '';
      });
      return;
    }
    final text = _inputedDigitsTextController.text;
    final textSelection = _inputedDigitsTextController.selection;
    final selectionLength = textSelection.end - textSelection.start;

    // There is a selection.
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      setState(() {
        _inputedDigitsTextController.text = newText;
        _inputedDigitsTextController.selection = textSelection.copyWith(
          baseOffset: textSelection.start,
          extentOffset: textSelection.start,
        );
      });

      return;
    }

    // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return;
    }

    // Delete the previous character
    final newStart = textSelection.start - 1;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    setState(() {
      _inputedDigitsTextController.text = newText;
      _inputedDigitsTextController.selection = textSelection.copyWith(
        baseOffset: newStart,
        extentOffset: newStart,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Spacer(),
            LogOutMenuAnchor(),
          ],
        ),
        // SizedBox(
        //   height: 40,
        //   child: ListView(
        //     children: [
        //       Text('faf'),
        //       Text('faf'),
        //       Text('faf'),
        //       Text('faf'),
        //     ],
        //   ),
        // ),
        const Spacer(),
        TextField(
          onChanged: (value) {},
          autofocus: true,
          cursorColor: Colors.green,
          keyboardType: TextInputType.none,
          textAlign: TextAlign.center,
          controller: _inputedDigitsTextController,
          decoration: const InputDecoration(border: InputBorder.none),
          style: const TextStyle(fontSize: 43, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Keypad(
              typedInPhoneNumber: _inputedDigitsTextController.text,
              onBackButtonPressed: _backspace,
              onKeyPressed: _addDigit,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
