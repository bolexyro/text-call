import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_call/screens/rich_message_editor.dart/audio_recorder_card.dart';
import 'package:text_call/screens/rich_message_editor.dart/image_displayer.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_quill_editor.dart';
import 'package:text_call/screens/rich_message_editor.dart/my_video_player.dart';
import 'package:text_call/screens/rich_message_editor.dart/preview_screen.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/camera_or_gallery.dart';
import 'package:text_call/widgets/dialogs/confirm_dialog.dart';

class RichMessageEditorScreen extends StatefulWidget {
  const RichMessageEditorScreen({
    super.key,
    this.bolexyroJson,
  });
  final Map<String, dynamic>? bolexyroJson;

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
  late final Future<String> _imageDirectoryPath;
  late final Future<String?> _videoDirectoryPath;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _imageDirectoryPath = messagesDirectoryPath(isTemporary:true, specificDirectory: 'images');
    _videoDirectoryPath = messagesDirectoryPath(isTemporary:true, specificDirectory: 'videos');

    if (widget.bolexyroJson != null) {
      //indexMainMediaMapPair =
      // "1": {
      //     "audio": "audioPath"
      // }
      for (final indexMainMediaMapPair in widget.bolexyroJson!.entries) {
        final mapMedia = indexMainMediaMapPair.value;

        if (mapMedia.keys.first == 'document') {
          _addTextEditor(
            initialBgColor: deJsonifyColorMapToColor(
              mapMedia['document']['backgroundColor'],
            ),
            withoutSetState: true,
            contollerParam: QuillController(
              document: Document.fromJson(
                jsonDecode(mapMedia['document']['quillDocJson']),
              ),
              selection: const TextSelection.collapsed(offset: 0),
            ),
          );
        }        

        if (mapMedia.keys.first == 'image') {
          final newIndex = ++index;
          final imagePath = mapMedia['image']['imagePaths']['local'] ??
              mapMedia['image']['imagePaths']['online'];
          _imagePathsMap[newIndex] = imagePath;
          _displayedWidgetsMap[newIndex] = ImageDisplayer(
            key: ValueKey(newIndex),
            keyInMap: newIndex,
            onDelete: _removeMediaWidget,
            imagePath: imagePath,
            isNetworkImage: mapMedia['image']['imagePaths']['local'] == null,
          );
        }

        if (mapMedia.keys.first == 'video') {
          final newIndex = ++index;
          final videoPath = mapMedia['video']['videoPaths']['local'] ??
              mapMedia['video']['videoPaths']['online'];
          _videoPathsMap[newIndex] = videoPath;
          _displayedWidgetsMap[newIndex] = MyVideoPlayer(
            key: ValueKey(newIndex),
            keyInMap: newIndex,
            onDelete: _removeMediaWidget,
            videoPath: videoPath,
            isNetworkVideo: mapMedia['video']['videoPaths']['local'] == null,
          );
        }

        if (mapMedia.keys.first == 'audio') {
          final audioPath = mapMedia['audio']['audioPaths']['local'] ??
              mapMedia['audio']['audioPaths']['online'];
          _addAudio(initialAudioPath: audioPath, withoutSetState: true);
          _getAudioPath(audioPath, index);
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

  Map<String, dynamic> _createMyOwnCustomDocumentJson() {
    final Map<String, dynamic> bolexyroJson = {};
    int index = 0;
    for (final kvPair in _displayedWidgetsMap.entries) {
      if (kvPair.value.runtimeType == MyQuillEditor &&
          _controllersMap[kvPair.key]!.document.toDelta().toJson()[0]
                  ['insert'] !=
              '\n') {
        final bgColor =
            _quillEditorBackgroundColorMap[kvPair.key] ?? Colors.white;
        bolexyroJson[index.toString()] = {
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
        bolexyroJson[index.toString()] = {
          'audio': {
            'audioPaths': {
              'online': null,
              'local': _audioPathsMap[kvPair.key]!
            },
          },
        };
      }

      if (kvPair.value.runtimeType == MyVideoPlayer) {
        bolexyroJson[index.toString()] = {
          'video': {
            'videoPaths': {
              'online': null,
              'local': _videoPathsMap[kvPair.key]!
            },
          },
        };
      }

      if (kvPair.value.runtimeType == ImageDisplayer) {
        bolexyroJson[index.toString()] = {
          'image': {
            'imagePaths': {
              'online': null,
              'local': _imagePathsMap[kvPair.key]!
            },
          },
        };
      }
      index++;
    }
    return bolexyroJson;
  }

  void _addTextEditor(
      {bool withoutSetState = false,
      QuillController? contollerParam,
      Color? initialBgColor}) {
    FocusManager.instance.primaryFocus?.unfocus();
    final newIndex = ++index;
    final controller = contollerParam ?? QuillController.basic();

    if (initialBgColor != null) {
      _quillEditorBackgroundColorMap[newIndex] = initialBgColor;
    }

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
    if (_audioPathsMap[key] != null) {
      deleteFile(_audioPathsMap[key]!);
    }

    if (_videoPathsMap[key] != null) {
      deleteFile(_videoPathsMap[key]!);
    }

    if (_imagePathsMap[key] != null) {
      deleteFile(_imagePathsMap[key]!);
    }
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

    final filePath = '${await _imageDirectoryPath}/${pickedImage.name}';
    pickedImage.saveTo(filePath);

    _imagePathsMap[newIndex] = filePath;

    setState(() {
      _displayedWidgetsMap[newIndex] = ImageDisplayer(
        key: ValueKey(newIndex),
        keyInMap: newIndex,
        onDelete: _removeMediaWidget,
        imagePath: filePath,
        isNetworkImage: false,
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

  void _getAudioPath(String? path, int index) async {
    if (path == null) {
      _audioPathsMap.remove(index);
      return;
    }
    _audioPathsMap[index] = path;
  }

  void _addVideo() async {
    FocusManager.instance.primaryFocus?.unfocus();

    ImageSource? source = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => const CameraOrGallery(
        forVideo: true,
      ),
    );
    final ImagePicker picker = ImagePicker();

    if (source == null) {
      return;
    }
    final XFile? pickedVideo = await picker.pickVideo(
      source: source,
    );
    if (pickedVideo == null) {
      return null;
    }

    final newIndex = ++index;

    final filePath = '${await _videoDirectoryPath}/${pickedVideo.name}';
    pickedVideo.saveTo(filePath);

    _videoPathsMap[newIndex] = filePath;

    setState(() {
      _displayedWidgetsMap[newIndex] = MyVideoPlayer(
        key: ValueKey(newIndex),
        keyInMap: newIndex,
        onDelete: _removeMediaWidget,
        videoPath: filePath,
        isNetworkVideo: false,
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

  bool _changesHaveBeenMade() {
    if (_createMyOwnCustomDocumentJson().isEmpty ||
        const DeepCollectionEquality()
            .equals(widget.bolexyroJson, _createMyOwnCustomDocumentJson())) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      // backgroundColor: kLightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          children: [
            IconButton(
              onPressed: () async {
                if (!_changesHaveBeenMade()) {
                  Navigator.of(context).pop();
                  return;
                }
                final bool? toDiscard = await showAdaptiveDialog(
                  context: context,
                  builder: (context) => const ConfirmDialog(
                    title: 'Discard changes',
                    subtitle:
                        'Are you sure you want to discard your changes? This action cannot be undone.',
                    mainButtonText: 'Discard',
                  ),
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
                    : ColorFilter.mode(
                        Theme.of(context).iconTheme.color!,
                        BlendMode.srcIn,
                      ),
              ),
            ),
            IconButton(
              onPressed: _addImage,
              icon: SvgPicture.asset(
                'assets/icons/add-image.svg',
                height: kIconHeight,
                colorFilter: isLightMode
                    ? null
                    : ColorFilter.mode(
                        Theme.of(context).iconTheme.color!,
                        BlendMode.srcIn,
                      ),
              ),
            ),
            IconButton(
              onPressed: _addVideo,
              icon: SvgPicture.asset(
                'assets/icons/add-video.svg',
                height: kIconHeight,
                colorFilter: isLightMode
                    ? null
                    : ColorFilter.mode(
                        Theme.of(context).iconTheme.color!,
                        BlendMode.srcIn,
                      ),
              ),
            ),
            IconButton(
              onPressed: _addTextEditor,
              icon: SvgPicture.asset(
                'assets/icons/add-text-editor.svg',
                height: kIconHeight,
                colorFilter: isLightMode
                    ? null
                    : ColorFilter.mode(
                        Theme.of(context).iconTheme.color!,
                        BlendMode.srcIn,
                      ),
              ),
            ),
            IconButton(
              onPressed: _goToPreviewScreen,
              icon: SvgPicture.asset(
                'assets/icons/preview.svg',
                height: kIconHeight,
                colorFilter: isLightMode
                    ? null
                    : ColorFilter.mode(
                        Theme.of(context).iconTheme.color!,
                        BlendMode.srcIn,
                      ),
              ),
            ),
            IconButton(
              onPressed: () {
                if (!_changesHaveBeenMade()) {
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.of(context).pop(_createMyOwnCustomDocumentJson());
              },
              icon: SvgPicture.asset(
                'assets/icons/file-done.svg',
                height: 30,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          if (!_changesHaveBeenMade()) {
            Navigator.of(context).pop();
            return;
          }
          final bool? toDiscard = await showAdaptiveDialog(
            context: context,
            builder: (context) => const ConfirmDialog(
              title: 'Discard changes',
              subtitle:
                  'Are you sure you want to discard your changes? This action cannot be undone.',
              mainButtonText: 'Discard',
            ),
          );
          if (toDiscard == true) {
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: _displayedWidgetsMap.isEmpty
              ? Center(
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
                )
              : ReorderableListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10),
                  scrollController: _scrollController,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      List<MapEntry<int, Widget>> entries =
                          _displayedWidgetsMap.entries.toList();

                      // Remove the item at the old index
                      final entry = entries.removeAt(oldIndex);

                      // Insert the item at the new index
                      entries.insert(newIndex, entry);

                      // Clear the original map and add the reordered entries
                      _displayedWidgetsMap
                        ..clear()
                        ..addEntries(entries);
                    });
                  },
                  children: _displayedWidgetsMap.values.toList(),
                ),
        ),
      ),
    );
  }
}
