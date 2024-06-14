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
  });

  final Contact contact;

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
    Navigator.of(context).pop();
  }

  void _showBlockMessageFlushBar(BuildContext context, WidgetRef ref) {
    _flushBarKey = showFlushBar(
      const Color.fromARGB(255, 0, 63, 114),
      mainButton: ElevatedButton(
        onPressed: () async {
          (_flushBarKey!.currentWidget as Flushbar).dismiss();
          showDialog(
              context: context,
              builder: (context) => const BlockMessageDialog());
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
  Widget build(BuildContext context) {
    bool thisContactIsBlocked =
        ref.watch(blockedContactsProvider).contains(widget.contact.phoneNumber);
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

class BlockMessageDialog extends StatelessWidget {
  const BlockMessageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController blockMessageController = TextEditingController(
        text:
            'SIKEEE!! It ain\'t working yet. I\'m sure you were about to write some mean message. 🤣');

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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
