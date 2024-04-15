import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/keypad_screen_widgets/keypad_button.dart';

class Keypad extends ConsumerWidget {
  const Keypad({
    super.key,
    required this.onBackButtonPressed,
    required this.onKeyPressed,
    required this.typedInPhoneNumber,
  });

  final void Function(String didit) onKeyPressed;
  final void Function({bool? longPress}) onBackButtonPressed;
  final String typedInPhoneNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      childAspectRatio: 1.3,
      crossAxisCount: 3,
      shrinkWrap: true,
      children: [
        KeypadButton(
          buttonText: '1',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '2',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '3',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '4',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '5',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '6',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '7',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '8',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '9',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '*',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '0',
          onButtonPressed: onKeyPressed,
        ),
        KeypadButton(
          buttonText: '#',
          onButtonPressed: onKeyPressed,
        ),
        Container(),
        Center(
          child: IconButton(
            onPressed: () async {
              if (await checkIfNumberExists(typedInPhoneNumber, context)) {
                final Contact callee =
                    await ref.read(contactsProvider.notifier).readAContact(
                              changeLocalToIntl(
                                  localPhoneNumber: typedInPhoneNumber),
                            ) ??
                        Contact(
                          name: 'Unknown',
                          phoneNumber: changeLocalToIntl(
                              localPhoneNumber: typedInPhoneNumber),
                        );

                showMessageWriterModalSheet(
                  context: context,
                  calleeName: callee.name,
                  calleePhoneNumber:
                      changeLocalToIntl(localPhoneNumber: typedInPhoneNumber),
                );
              }
            },
            icon: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.message,
                size: 25,
              ),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        InkWell(
          radius: 15,
          borderRadius: BorderRadius.circular(20),
          customBorder: const CircleBorder(),
          splashColor: Colors.grey,
          onTap: () {
            onBackButtonPressed();
          },
          onLongPress: () => onBackButtonPressed(longPress: true),
          child: const Icon(Icons.backspace),
        ),
      ],
    );
  }
}
