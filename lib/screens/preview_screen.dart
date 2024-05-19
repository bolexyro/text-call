import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_embeds.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({
    super.key,
    required this.documentJson,
  });

  final String documentJson;

  @override
  Widget build(BuildContext context) {
    final QuillController controller = QuillController(
      document: Document.fromJson(jsonDecode(documentJson)),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
      
    );
    return Scaffold(
      appBar: AppBar(),
      
      body: QuillEditor.basic(
        configurations: QuillEditorConfigurations(
          showCursor: false,
          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
          scrollable: true,
          autoFocus: true,
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          keyboardAppearance: Theme.of(context).brightness,
          placeholder: 'Start typing....',
          controller: controller,
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('de'),
          ),
        ),
      ),
    );
  }
}
