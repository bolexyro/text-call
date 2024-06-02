import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/widgets/dialogs/choose_color_dialog.dart';

class MyQuillEditor extends StatefulWidget {
  const MyQuillEditor({
    super.key,
    required this.onDelete,
    required this.keyInMap,
    required this.controller,
    required this.onBackgroundColorChanged,
    this.initialBgColor,
  });

  final int keyInMap;
  final void Function(int key) onDelete;
  final void Function(int key, Color newColor) onBackgroundColorChanged;
  final QuillController controller;
  final Color? initialBgColor;

  @override
  State<MyQuillEditor> createState() => _MyQuillEditorState();
}

class _MyQuillEditorState extends State<MyQuillEditor> {
  late final QuillController _controller;
  late Color _backgroundColor;
  bool _collapseToolbar = true;
  Color? lastColorUsedByUser;

  @override
  initState() {
    _controller = widget.controller;
    _backgroundColor = widget.initialBgColor ?? Colors.white;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillToolbar.simple(
          configurations: QuillSimpleToolbarConfigurations(            
            multiRowsDisplay: !_collapseToolbar,
            customButtons: [
              QuillToolbarCustomButtonOptions(
                icon: Row(
                  children: [
                    const Text('BG'),
                    SvgPicture.asset(
                      'assets/icons/background-color.svg',
                      height: kIconHeight,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).iconTheme.color!,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Color? selectedColor = _backgroundColor;
                  selectedColor = await showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return ChooseColorDialog(
                        initialPickerColor: lastColorUsedByUser ??
                            const Color.fromARGB(255, 153, 83, 78),
                      );
                    },
                  );
                  setState(() {
                    _backgroundColor = selectedColor ?? _backgroundColor;
                  });
                  widget.onBackgroundColorChanged(
                      widget.keyInMap, _backgroundColor);
                },
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
                  'assets/icons/delete.svg',
                  colorFilter: const ColorFilter.mode(
                    Color.fromARGB(255, 255, 57, 43),
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => widget.onDelete(widget.keyInMap),
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
        Padding(
          padding: const EdgeInsets.only(bottom: kSpaceBtwWidgetsInPreviewOrRichTextEditor),
          child: Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            height: 200,
            child: Theme(
              data: kLightTheme,
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  scrollable: true,
                  autoFocus: false,
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
          ),
        ),
      ],
    );
  }
}
