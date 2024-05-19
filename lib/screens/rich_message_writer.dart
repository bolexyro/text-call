import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';

class RichMessageWriter extends StatefulWidget {
  const RichMessageWriter({super.key});

  @override
  State<RichMessageWriter> createState() => _RichMessageWriterState();
}

class _RichMessageWriterState extends State<RichMessageWriter> {
  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              customButtons: [
                QuillToolbarCustomButtonOptions(
                  icon: SvgPicture.asset(
                    'assets/icons/file-done.svg',
                    height: 30,
                  ),
                  onPressed: () {},
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
