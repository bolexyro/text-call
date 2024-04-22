import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatefulWidget {
  const ConfirmDeleteDialog({
    super.key,
    required this.contactName,
  });

  final String contactName;

  @override
  State<ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog.adaptive(
      title: Text(
        'Are you sure you want to delete ${widget.contactName}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          color: isDarkMode
              ? Theme.of(context).colorScheme.onErrorContainer
              : Theme.of(context).colorScheme.onError,
        ),
      ),
      backgroundColor: isDarkMode
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.error,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: isDarkMode
                ? Theme.of(context).colorScheme.onErrorContainer
                : Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 42, 6, 3)),
          child: const Text('Delete'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceAround,
    );
  }
}
