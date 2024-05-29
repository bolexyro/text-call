import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_call/screens/rich_message_editor.dart/audio_recorder_card.dart';
import 'package:text_call/screens/rich_message_editor.dart/confirm_discard_dialog.dart';
import 'package:text_call/screens/rich_message_editor.dart/image_displayer.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_quill_editor.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_video_player.dart';
import 'package:text_call/screens/rich_message_editor.dart/preview_screen.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/camera_or_gallery.dart';

class RichMessageEditorScreen extends StatefulWidget {
  const RichMessageEditorScreen({
    super.key,
    this.bolexyroJSon,
  });
  final Map<int, Map<String, dynamic>>? bolexyroJSon;

  @override
  State<RichMessageEditorScreen> createState() =>
      _RichMessageEditorScreenState();
}

class _RichMessageEditorScreenState extends State<RichMessageEditorScreen> {
  // this index would be the keys for the widgets in the list
  int index = -1;
  late final Map<int, Widget> _displayedWidgetsMap = {};
  late final Map<int, QuillController> _controllersMap = {};
  late final Map<int, String> _audioPathsMap = {};
  late final Map<int, String> _imagePathsMap = {};
  late final Map<int, String> _videoPathsMap = {};
  late final Map<int, Color> _quillEditorBackgroundColorMap = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (widget.bolexyroJSon != null) {
      //indexMainMediaMapPair =
      // "1": {
      //     "audio": "audioPath"
      // }
      for (final indexMainMediaMapPair in widget.bolexyroJSon!.entries) {
        final mapMedia = indexMainMediaMapPair.value;
        if (mapMedia.keys.first == 'document') {
          _addTextEditor(
            initialBgColor:
                deJsonifyColor(mapMedia['document']['backgroundColor']),
            withoutSetState: true,
            contollerParam: QuillController(
              document: Document.fromJson(
                jsonDecode(
                  mapMedia['document']['quillDocJson'],
                ),
              ),
              selection: const TextSelection.collapsed(offset: 0),
            ),
          );
        }

        if (mapMedia.keys.first == 'image') {
          final newIndex = ++index;
          _imagePathsMap[newIndex] = mapMedia['image'];
          _displayedWidgetsMap[newIndex] = ImageDisplayer(
            key: ValueKey(newIndex),
            keyInMap: newIndex,
            onDelete: _removeMediaWidget,
            imageFile: File(mapMedia['image']),
          );
        }

        if (mapMedia.keys.first == 'video') {
          final newIndex = ++index;
          _videoPathsMap[newIndex] = mapMedia['video'];
          _displayedWidgetsMap[newIndex] = MyVideoPlayer(
            key: ValueKey(newIndex),
            keyInMap: newIndex,
            onDelete: _removeMediaWidget,
            videoFile: File(mapMedia['video']),
          );
        }

        if (mapMedia.keys.first == 'audio') {
          _addAudio(initialAudioPath: mapMedia['audio'], withoutSetState: true);
          _getAudioPath(mapMedia['audio'], index);
        }
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Map<int, Map<String, dynamic>> _createMyOwnCustomDocumentJson() {
    final Map<int, Map<String, dynamic>> bolexyroJSon = {};
    int index = 0;
    for (final kvPair in _displayedWidgetsMap.entries) {
      if (kvPair.value.runtimeType == MyQuillEditor &&
          _controllersMap[kvPair.key]!.document.toDelta().toJson()[0]
                  ['insert'] !=
              '\n') {
        final bgColor =
            _quillEditorBackgroundColorMap[kvPair.key] ?? Colors.white;
        bolexyroJSon[index] = {
          'document': {
            'backgroundColor': {
              'alpha': bgColor.alpha,
              'red': bgColor.red,
              'blue': bgColor.blue,
              'green': bgColor.green,
            },
            'quillDocJson': jsonEncode(
              _controllersMap[kvPair.key]!.document.toDelta().toJson(),
            ),
          },
        };
      }
      if (kvPair.value.runtimeType == AudioRecorderCard &&
          _audioPathsMap[kvPair.key] != null) {
        bolexyroJSon[index] = {'audio': _audioPathsMap[kvPair.key]!};
      }

      if (kvPair.value.runtimeType == MyVideoPlayer) {
        bolexyroJSon[index] = {'video': _videoPathsMap[kvPair.key]!};
      }

      if (kvPair.value.runtimeType == ImageDisplayer) {
        bolexyroJSon[index] = {'image': _imagePathsMap[kvPair.key]!};
      }
      index++;
    }
    return bolexyroJSon;
  }

  void _addTextEditor(
      {bool withoutSetState = false,
      QuillController? contollerParam,
      Color? initialBgColor}) {
    FocusManager.instance.primaryFocus?.unfocus();
    final newIndex = ++index;
    final controller = contollerParam ?? QuillController.basic();

    if (withoutSetState) {
      _controllersMap[newIndex] = controller;
      _displayedWidgetsMap[newIndex] = MyQuillEditor(
        initialBgColor: initialBgColor,
        onBackgroundColorChanged: _changeAnEditorsBgColor,
        key: ValueKey(newIndex),
        controller: controller,
        keyInMap: index,
        onDelete: _removeMediaWidget,
      );
    } else {
      setState(() {
        _controllersMap[newIndex] = controller;
        _displayedWidgetsMap[newIndex] = MyQuillEditor(
          onBackgroundColorChanged: _changeAnEditorsBgColor,
          key: ValueKey(newIndex),
          controller: controller,
          keyInMap: index,
          onDelete: _removeMediaWidget,
        );
      });
      _scrollToEnd();
    }
  }

  void _removeMediaWidget(int key) {
    setState(() {
      _displayedWidgetsMap.remove(key);
      _controllersMap.remove(key);
      _audioPathsMap.remove(key);
      _imagePathsMap.remove(key);
      _videoPathsMap.remove(key);
      _quillEditorBackgroundColorMap.remove(key);
    });
  }

  void _changeAnEditorsBgColor(int key, Color color) {
    _quillEditorBackgroundColorMap[key] = color;
  }

  void _addImage() async {
    FocusManager.instance.primaryFocus?.unfocus();

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

    final newIndex = ++index;

    _imagePathsMap[newIndex] = pickedImage.path;
    setState(() {
      _displayedWidgetsMap[newIndex] = ImageDisplayer(
        key: ValueKey(newIndex),
        keyInMap: newIndex,
        onDelete: _removeMediaWidget,
        imageFile: File(pickedImage.path),
      );
    });

    _scrollToEnd();
  }

  void _addAudio({bool withoutSetState = false, String? initialAudioPath}) {
    FocusManager.instance.primaryFocus?.unfocus();

    if (withoutSetState) {
      final newIndex = ++index;
      _displayedWidgetsMap[newIndex] = AudioRecorderCard(
        initialAudioPath: initialAudioPath,
        key: ValueKey(newIndex),
        keyInMap: newIndex,
        onDelete: _removeMediaWidget,
        savePath: _getAudioPath,
      );
    } else {
      setState(() {
        final newIndex = ++index;
        _displayedWidgetsMap[newIndex] = AudioRecorderCard(
          key: ValueKey(newIndex),
          keyInMap: newIndex,
          onDelete: _removeMediaWidget,
          savePath: _getAudioPath,
        );
      });
      _scrollToEnd();
    }
  }

  void _getAudioPath(String path, int index) async {
    _audioPathsMap[index] = path;
  }

  void _addVideo() async {
    FocusManager.instance.primaryFocus?.unfocus();

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
    final newIndex = ++index;
    _videoPathsMap[newIndex] = pickedVideo.path;
    setState(() {
      _displayedWidgetsMap[newIndex] = MyVideoPlayer(
        key: ValueKey(newIndex),
        keyInMap: newIndex,
        onDelete: _removeMediaWidget,
        videoFile: File(pickedVideo.path),
      );
    });

    _scrollToEnd();
  }

  void _goToPreviewScreen() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PreviewScreen(
          bolexyroJson: _createMyOwnCustomDocumentJson(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 6.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (_displayedWidgetsMap.isEmpty ||
                          const DeepCollectionEquality().equals(
                              widget.bolexyroJSon,
                              _createMyOwnCustomDocumentJson())) {
                        Navigator.of(context).pop();
                        return;
                      }
                      final bool? toDiscard = await showAdaptiveDialog(
                        context: context,
                        builder: (context) => const ConfirmDiscardDialog(),
                      );
                      if (toDiscard == true) {
                        Navigator.of(context).pop();
                      }
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
                    onPressed: _goToPreviewScreen,
                    icon: SvgPicture.asset(
                      'assets/icons/preview.svg',
                      height: kIconHeight,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLightMode)
              Container(
                color: Colors.white,
                height: 10.0,
              ),
            if (_displayedWidgetsMap.isEmpty)
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
            if (_displayedWidgetsMap.isNotEmpty)
              Expanded(
                child: Container(
                  color: !isLightMode ? Colors.white : null,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 10),
                      child: Column(
                        children: _displayedWidgetsMap.values.toList(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
