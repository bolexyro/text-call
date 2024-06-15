import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/blocked_contacts_provider.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/dialogs/confirm_dialog.dart';

class OptionsMenuAnchor extends ConsumerStatefulWidget {
  const OptionsMenuAnchor({
    super.key,
    required this.contact,
    this.onContactDeleted,
  });

  final Contact contact;
  final void Function(Contact deletedContact)? onContactDeleted;

  @override
  ConsumerState<OptionsMenuAnchor> createState() => _OptionsMenuAnchorState();
}

class _OptionsMenuAnchorState extends ConsumerState<OptionsMenuAnchor> {
  GlobalKey? _flushBarKey;

  void _showDeleteDialog() async {
    final bool? toDelete = await showAdaptiveDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete Contact - ${widget.contact.name}',
        subtitle: 'This action cannot be undone',
        mainButtonText: 'Delete',
      ),
    );
    if (toDelete != true) {
      return;
    }
    ref
        .read(contactsProvider.notifier)
        .deleteContact(ref, widget.contact.phoneNumber);
    if (widget.onContactDeleted != null) {
      widget.onContactDeleted!(widget.contact);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showBlockMessageFlushBar(BuildContext context, WidgetRef ref) {
    _flushBarKey = showFlushBar(
      const Color.fromARGB(255, 0, 63, 114),
      mainButton: ElevatedButton(
        onPressed: () async {
          (_flushBarKey!.currentWidget as Flushbar).dismiss();
          showDialog(
            context: context,
            builder: (context) => BlockMessageDialog(
              phoneNumber: widget.contact.phoneNumber,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        child: const Text('Ok'),
      ),
      'Would you like to send them a default message if they call you.',
      FlushbarPosition.TOP,
      context,
    );
    ref
        .read(blockedContactsProvider.notifier)
        .addNewBlockedContact(widget.contact.phoneNumber);
  }

  @override
  Widget build(BuildContext contextp) {
    bool thisContactIsBlocked = ref
        .watch(blockedContactsProvider)
        .map((eachJsonString) => jsonDecode(eachJsonString)['phoneNumber'])
        .contains(widget.contact.phoneNumber);
    return MenuAnchor(
      menuChildren: <Widget>[
        if (!widget.contact.isMyContact)
          MenuItemButton(
            onPressed: _showDeleteDialog,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/delete.svg',
                  colorFilter: const ColorFilter.mode(
                    Color.fromARGB(255, 255, 57, 43),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                const Text('Delete'),
              ],
            ),
          ),
        if (!widget.contact.isMyContact)
          MenuItemButton(
            onPressed: () => thisContactIsBlocked
                ? ref
                    .read(blockedContactsProvider.notifier)
                    .unblockContact(ref, widget.contact.phoneNumber)
                : _showBlockMessageFlushBar(context, ref),
            child: Row(
              children: [
                Icon(
                  Icons.block,
                  color: thisContactIsBlocked
                      ? Colors.green
                      : const Color.fromARGB(255, 255, 57, 43),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(thisContactIsBlocked ? 'Unblock' : 'Block'),
              ],
            ),
          ),
        const MenuItemButton(
          child: Row(
            children: [
              Icon(Icons.qr_code),
              SizedBox(
                width: 12,
              ),
              Text('QR Code'),
            ],
          ),
        ),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        );
      },
    );
  }
}

class BlockMessageDialog extends ConsumerWidget {
  const BlockMessageDialog({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController blockMessageController =
        TextEditingController(text: 'You suck.');

    return AlertDialog.adaptive(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: blockMessageController,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(blockedContactsProvider.notifier)
                      .updateContactBlockMessage(
                          phoneNumber, blockMessageController.text);
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
