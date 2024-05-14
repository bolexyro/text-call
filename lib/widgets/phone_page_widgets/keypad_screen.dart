import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/screens/tablet_contact_details_screen.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_details.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_letter_avatar.dart';
import 'package:text_call/widgets/keypad_screen_widgets/keypad.dart';

class KeypadScreen extends ConsumerStatefulWidget {
  const KeypadScreen({
    super.key,
    required this.scaffoldKey,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  ConsumerState<KeypadScreen> createState() => _KeypadScreenState();
}

class _KeypadScreenState extends ConsumerState<KeypadScreen> {
  final _inputedDigitsTextController = TextEditingController(text: '');

  List<Contact>? _contacsThatMatchPattern = [];

  List<Contact> _getContactsWithMatch(String pattern) {
    if (pattern == '') {
      return [];
    }
    return ref
        .read(contactsProvider)
        .where((contact) =>
            contact.localPhoneNumber.contains(pattern) ||
            contact.phoneNumber.contains(pattern))
        .toList();
  }

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
    _contacsThatMatchPattern = _getContactsWithMatch(newText);

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
      _contacsThatMatchPattern = _getContactsWithMatch('');

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
      _contacsThatMatchPattern = _getContactsWithMatch(newText);

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
    _contacsThatMatchPattern = _getContactsWithMatch(newText);

    setState(() {
      _inputedDigitsTextController.text = newText;
      _inputedDigitsTextController.selection = textSelection.copyWith(
        baseOffset: newStart,
        extentOffset: newStart,
      );
    });
  }

  void _goToContactDetailsScreen(Contact contact) {
    const stackPadding = EdgeInsets.symmetric(horizontal: 10);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaQuery.sizeOf(context).width > tabletWidth
            ? TabletContactDetailsScreen(contact: contact)
            : SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back_ios_new),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        Expanded(
                          child: ContactDetails(
                            contact: contact,
                            stackContainerWidths:
                                MediaQuery.sizeOf(context).width -
                                    stackPadding.horizontal,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                widget.scaffoldKey.currentState!.openDrawer();
              },
              icon: SvgPicture.asset(
                'assets/icons/hamburger-menu.svg',
                height: 30,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color ?? Colors.grey,
                    BlendMode.srcIn),
              ),
            ),
          ],
        ),
        Expanded(
          child: _contacsThatMatchPattern == null
              ? const Text('')
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ListView(
                    children: [
                      for (final contact in _contacsThatMatchPattern!)
                        ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              _goToContactDetailsScreen(contact);
                            },
                            child: contact.imagePath != null
                                ? Hero(
                                    tag: contact.phoneNumber,
                                    child: ContactAvatarCircle(
                                      avatarRadius: 20,
                                      imagePath: contact.imagePath,
                                    ),
                                  )
                                : ContactLetterAvatar(
                                    contactName: contact.name),
                          ),
                          title: Text(contact.name),
                          onTap: () {
                            _inputedDigitsTextController.text =
                                contact.localPhoneNumber;
                            setState(() {
                              _contacsThatMatchPattern = _getContactsWithMatch(
                                  _inputedDigitsTextController.text);
                            });
                          },
                        )
                    ],
                  ),
                ),
        ),
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
        Keypad(
          typedInPhoneNumber: _inputedDigitsTextController.text,
          onBackButtonPressed: _backspace,
          onKeyPressed: _addDigit,
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
