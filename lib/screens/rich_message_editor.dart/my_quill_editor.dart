import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/screens/preview_screen.dart';
import 'package:text_call/utils/constants.dart';

class MyQuillEditor extends StatefulWidget {
  const MyQuillEditor({super.key});

  @override
  State<MyQuillEditor> createState() => _MyQuillEditorState();
}

class _MyQuillEditorState extends State<MyQuillEditor> {
  final QuillController _controller = QuillController.basic();
  bool _collapseToolbar = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              multiRowsDisplay: !_collapseToolbar,
              customButtons: [
                QuillToolbarCustomButtonOptions(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Color.fromARGB(255, 255, 57, 43),
                    ),
                  ),
                  onPressed: () {},
                ),
                QuillToolbarCustomButtonOptions(
                  icon: RotatedBox(
                    quarterTurns: _collapseToolbar ? 2 : 0,
                    child: SvgPicture.asset(
                      'assets/icons/collapse.svg',
                      height: kIconHeight,
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
                    print(json);
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
          Container(
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(10)),
            height: 200,
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                scrollable: true,
                autoFocus: true,
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
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
