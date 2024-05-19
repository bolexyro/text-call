import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_embeds.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/screens/preview_screen.dart';

class RichMessageWriter extends StatefulWidget {
  const RichMessageWriter({super.key});

  @override
  State<RichMessageWriter> createState() => _RichMessageWriterState();
}

class _RichMessageWriterState extends State<RichMessageWriter> {
  final QuillController _controller = QuillController.basic();
  bool _collapseToolbar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // showAdaptiveDialog(context: context, builder: (context) => AlertDialog.adaptive(
            //   content: ,
            // ))
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Column(
        children: [
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              multiRowsDisplay: !_collapseToolbar,
              customButtons: [
                QuillToolbarCustomButtonOptions(
                  icon: RotatedBox(
                    quarterTurns: _collapseToolbar ? 2 : 0,
                    child: SvgPicture.asset(
                      'assets/icons/collapse.svg',
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).iconTheme.color!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  onPressed: () => setState(() {
                    _collapseToolbar = !_collapseToolbar;
                  }),
                ),
                QuillToolbarCustomButtonOptions(
                  icon: SvgPicture.asset(
                    'assets/icons/file-done.svg',
                    height: 30,
                  ),
                  onPressed: () {
                    final json =
                        jsonEncode(_controller.document.toDelta().toJson());
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PreviewScreen(documentJson: json),
                      ),
                    );
                  },
                ),
              ],
              controller: _controller,
              toolbarIconAlignment: WrapAlignment.end,
              showSmallButton: false,
              showSuperscript: false,
              showSubscript: false,
              showClipboardCopy: false,
              showClipboardCut: false,
              showClipboardPaste: false,
              showLink: false,
              showSearchButton: false,
              showFontSize: false,
              showCodeBlock: false,
              showInlineCode: false,
              sharedConfigurations: const QuillSharedConfigurations(
                locale: Locale('de'),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Expanded(
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
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
                controller: _controller,
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('de'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
