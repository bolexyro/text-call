import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatefulWidget {
  const ConfirmDeleteDialog({super.key});

  @override
  State<ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text(
        'Are you sure you want to delete',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 25),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 174, 168),
      actions: [
        TextButton(
          onPressed: () {Navigator.of(context).pop();},
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Cancel'),

        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceAround,
    );
  }
}
