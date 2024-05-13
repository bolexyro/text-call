// import 'package:auto_height_grid_view/auto_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/keypad_screen_widgets/keypad_button.dart';

class Keypad extends ConsumerStatefulWidget {
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
  ConsumerState<Keypad> createState() => _KeypadState();
}

class _KeypadState extends ConsumerState<Keypad> {
  bool _isCheckingIfNumberExists = false;

  void phoneNumberVerification(BuildContext context, WidgetRef ref) async {
    setState(() {
      _isCheckingIfNumberExists = true;
    });
    final bool phoneNumberIsValid =
        isPhoneNumberValid(widget.typedInPhoneNumber);
    if (phoneNumberIsValid == false) {
      showADialog(
          header: 'Error!!',
          body: 'Enter a valid phone number',
          context: context,
          buttonText: 'ok',
          onPressed: () => Navigator.of(context).pop());
      setState(() {
        _isCheckingIfNumberExists = false;
      });
      return;
    }
    String phoneNumber = changeLocalToIntl(widget.typedInPhoneNumber);
    final bool numberExists = await checkIfNumberExists(
      phoneNumber,
    );
    if (numberExists == false) {
      showADialog(
          header: 'Error!!',
          body: 'Number doesn\'t exist',
          context: context,
          buttonText: 'ok',
          onPressed: () => Navigator.of(context).pop());
      setState(() {
        _isCheckingIfNumberExists = false;
      });
      return;
    }

    final Contact callee = ref
            .read(contactsProvider)
            .where(
              (contact) =>
                  contact.phoneNumber ==
                  changeLocalToIntl(
                    widget.typedInPhoneNumber,
                  ),
            )
            .toList()
            .isNotEmpty
        ? ref
            .read(contactsProvider)
            .where(
              (contact) =>
                  contact.phoneNumber ==
                  changeLocalToIntl(
                    widget.typedInPhoneNumber,
                  ),
            )
            .toList()[0]
        : Contact(
            name: '',
            phoneNumber: changeLocalToIntl(widget.typedInPhoneNumber),
            imagePath: null,
          );

    setState(() {
      _isCheckingIfNumberExists = false;
    });

    showMessageWriterModalSheet(
      context: context,
      calleeName: callee.name,
      calleePhoneNumber: changeLocalToIntl(widget.typedInPhoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keypadWidth = MediaQuery.sizeOf(context).width * .7;
    final keypadHeight = MediaQuery.sizeOf(context).height * .5;
    final buttonWidth = keypadWidth / 3;
    final buttonHeight = keypadHeight / 5;

    print(buttonHeight);

    return SizedBox(
      height: keypadHeight,
      width: keypadWidth,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '1',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '2',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '3',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '4',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '5',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '6',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '7',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '8',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '9',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '*',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '0',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: KeypadButton(
                  buttonText: '#',
                  onButtonPressed: widget.onKeyPressed,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _isCheckingIfNumberExists
                      ? () {}
                      : () {
                          phoneNumberVerification(context, ref);
                        },
                  child: Padding(
                    padding: EdgeInsets.all(buttonHeight * .1),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding:  EdgeInsets.all(buttonHeight * .15),
                        child: SvgPicture.asset(
                          'assets/icons/message-ring.svg',
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    widget.onBackButtonPressed();
                  },
                  onLongPress: () =>
                      widget.onBackButtonPressed(longPress: true),
                  child: const Icon(Icons.backspace),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
