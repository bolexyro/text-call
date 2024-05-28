import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class DocDisplayer extends StatelessWidget {
  const DocDisplayer({
    super.key,
    required this.documentJson,
  });

  final String documentJson;

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.blue, Colors.red, Colors.purple, Colors.green];
    final controller = QuillController(
      document: Document.fromJson(jsonDecode(documentJson)),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );

    return Container(
      color: colors[Random().nextInt(4)],
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
