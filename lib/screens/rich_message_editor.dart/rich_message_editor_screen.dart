import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_call/screens/rich_message_editor.dart/audio_recorder_card.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_quill_editor.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_video_player.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/widgets/camera_or_gallery.dart';

class RichMessageEditorScreen extends StatefulWidget {
  const RichMessageEditorScreen({super.key});

  @override
  State<RichMessageEditorScreen> createState() =>
      _RichMessageEditorScreenState();
}

class _RichMessageEditorScreenState extends State<RichMessageEditorScreen> {
  final List<Widget> _displayedWidgets = [];
  void _addTextEditor() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _displayedWidgets.add(const MyQuillEditor());
    });
  }

  void _addImage() async {
    ImageSource? source = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => const CameraOrGallery(),
    );
    final ImagePicker picker = ImagePicker();

    if (source == null) {
      return;
    }
    final XFile? pickedImage = await picker.pickImage(source: source);
    if (pickedImage == null) {
      return null;
    }
    setState(() {
      _displayedWidgets.add(
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 550,
              child: Image.file(
                File(pickedImage.path),
              ),
            ),
            Positioned(
              right: -10,
              top: -10,
              child: Container(
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
            ),
          ],
        ),
      );
    });
  }

  void _addAudio() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _displayedWidgets.add(
        const AudioRecorderCard(),
      );
    });
  }

  void _addVideo() async {
    ImageSource? source = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => const CameraOrGallery(),
    );
    final ImagePicker picker = ImagePicker();

    if (source == null) {
      return;
    }
    final XFile? pickedVideo = await picker.pickVideo(source: source);
    if (pickedVideo == null) {
      return null;
    }
    setState(() {
      _displayedWidgets.add(
        MyVideoPlayer(
          videoFile: File(pickedVideo.path),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
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
                    onPressed: _addAudio,
                    icon: SvgPicture.asset(
                      'assets/icons/audio.svg',
                      height: kIconHeight,
                      colorFilter: isLightMode
                          ? null
                          : ColorFilter.mode(Theme.of(context).iconTheme.color!,
                              BlendMode.srcIn),
                    ),
                  ),
                  IconButton(
                    onPressed: _addImage,
                    icon: SvgPicture.asset(
                      'assets/icons/add-image.svg',
                      height: kIconHeight,
                      colorFilter: isLightMode
                          ? null
                          : ColorFilter.mode(Theme.of(context).iconTheme.color!,
                              BlendMode.srcIn),
                    ),
                  ),
                  IconButton(
                    onPressed: _addVideo,
                    icon: SvgPicture.asset(
                      'assets/icons/add-video.svg',
                      height: kIconHeight,
                      colorFilter: isLightMode
                          ? null
                          : ColorFilter.mode(Theme.of(context).iconTheme.color!,
                              BlendMode.srcIn),
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
            if (_displayedWidgets.isEmpty)
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
            if (_displayedWidgets.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(children: _displayedWidgets),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
