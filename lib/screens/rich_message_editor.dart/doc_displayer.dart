import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class DocDisplayer extends StatelessWidget {
  const DocDisplayer({
    super.key,
    required this.documentJson,
    required this.backgroundColor,
  });

  final String documentJson;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    final controller = QuillController(
      document: Document.fromJson(jsonDecode(documentJson)),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(5),
        color: backgroundColor,
      ),
      child: QuillEditor.basic(
        configurations: QuillEditorConfigurations(
          showCursor: false,
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          controller: controller,
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('de'),
          ),
        ),
      ),
    );
  }
}
