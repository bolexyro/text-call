import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_quill_editor.dart';
import 'package:text_call/utils/constants.dart';

class RichMessageEditorScreen extends StatefulWidget {
  const RichMessageEditorScreen({super.key});

  @override
  State<RichMessageEditorScreen> createState() =>
      _RichMessageEditorScreenState();
}

class _RichMessageEditorScreenState extends State<RichMessageEditorScreen> {
  final List<Widget> displayedWidgets = [];
  void _addTextEditor() {
    setState(() {
      FocusManager.instance.primaryFocus?.unfocus();
      displayedWidgets.add(const MyQuillEditor());
    });
  }

  void _addImage() {}

  void _addAudio() {}

  void _addVideo() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 7.0, top: 10.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/icons/audio.svg',
                      height: kIconHeight,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/icons/add-image.svg',
                      height: kIconHeight,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/icons/add-video.svg',
                      height: kIconHeight,
                    ),
                  ),
                  IconButton(
                    onPressed: _addTextEditor,
                    icon: SvgPicture.asset(
                      'assets/icons/add-text-editor.svg',
                      height: kIconHeight,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      'assets/icons/file-done.svg',
                      height: kIconHeight,
                    ),
                  ),
                ],
              ),
            ),
            if (displayedWidgets.isEmpty)
              Expanded(
                child: Center(
                  child: Transform.rotate(
                    angle: .785,
                    child: Text(
                      'Tabula Rasa',
                      style: GoogleFonts.baskervville(
                        textStyle: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (displayedWidgets.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: displayedWidgets),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
