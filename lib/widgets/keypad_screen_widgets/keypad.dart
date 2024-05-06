import 'package:auto_height_grid_view/auto_height_grid_view.dart';
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
    String phoneNumber =
        changeLocalToIntl(localPhoneNumber: widget.typedInPhoneNumber);
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
                    localPhoneNumber: widget.typedInPhoneNumber,
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
                    localPhoneNumber: widget.typedInPhoneNumber,
                  ),
            )
            .toList()[0]
        : Contact(
            name: '',
            phoneNumber:
                changeLocalToIntl(localPhoneNumber: widget.typedInPhoneNumber),
            imagePath: null,
          );

    setState(() {
      _isCheckingIfNumberExists = false;
    });

    showMessageWriterModalSheet(
      context: context,
      calleeName: callee.name,
      calleePhoneNumber:
          changeLocalToIntl(localPhoneNumber: widget.typedInPhoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return AutoHeightGridView(
    //   itemCount: 12,
    //   crossAxisCount: 3,
    //   physics: const BouncingScrollPhysics(),
    //   padding: const EdgeInsets.all(12),
    //   shrinkWrap: true,
    //   builder: (context, index) {
    //     final buttons = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    //     if (index == 9) {
    //       return Container();
    //     }
    //     if (index == 10) {
    //       return Center(
    //         child: IconButton(
    //           onPressed: _isCheckingIfNumberExists
    //               ? () {}
    //               : () {
    //                   phoneNumberVerification(context, ref);
    //                 },
    //           icon: Padding(
    //             padding: const EdgeInsets.all(5),
    //             child: SvgPicture.asset(
    //               'assets/icons/message-ring.svg',
    //               height: 30,
    //               colorFilter:
    //                   const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    //             ),
    //           ),
    //           style: IconButton.styleFrom(
    //             backgroundColor: Colors.blue,
    //             foregroundColor: Colors.white,
    //           ),
    //         ),
    //       );
    //     }
    //     if (index == 11) {
    //       return InkWell(
    //         customBorder: const CircleBorder(),
    //         splashColor: Colors.grey,
    //         onTap: () {
    //           widget.onBackButtonPressed();
    //         },
    //         onLongPress: () => widget.onBackButtonPressed(longPress: true),
    //         child: const Center(
    //           child: Padding(
    //             padding: EdgeInsets.all(18.0),
    //             child: Icon(Icons.backspace),
    //           ),
    //         ),
    //       );
    //     }
    //     return KeypadButton(
    //         buttonText: buttons[index], onButtonPressed: widget.onKeyPressed);
    //   },
    // );
    return GridView.count(
      childAspectRatio: 1.3,
      crossAxisCount: 3,
      shrinkWrap: true,
      children: [
        KeypadButton(
          buttonText: '1',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '2',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '3',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '4',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '5',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '6',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '7',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '8',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '9',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '*',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '0',
          onButtonPressed: widget.onKeyPressed,
        ),
        KeypadButton(
          buttonText: '#',
          onButtonPressed: widget.onKeyPressed,
        ),
        Container(),
        Center(
          child: IconButton(
            onPressed: _isCheckingIfNumberExists
                ? () {}
                : () {
                    phoneNumberVerification(context, ref);
                  },
            icon: Padding(
              padding: const EdgeInsets.all(5),
              child: SvgPicture.asset(
                'assets/icons/message-ring.svg',
                height: 30,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        InkWell(
          customBorder: const CircleBorder(),
          // splashColor: Colors.grey,
          onTap: () {
            widget.onBackButtonPressed();
          },
          onLongPress: () => widget.onBackButtonPressed(longPress: true),
          child: const Icon(Icons.backspace),
        ),
      ],
    );
  }
}
