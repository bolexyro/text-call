import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:text_call/utils/constants.dart';

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
      margin: const EdgeInsets.only(
          bottom: kSpaceBtwWidgetsInPreviewOrRichTextEditor),
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
      ),
      child: QuillEditor.basic(
        configurations: QuillEditorConfigurations(
          showCursor: false,
          padding: const EdgeInsets.all(12),
          controller: controller,
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('de'),
          ),
        ),
      ),
    );
  }
}
