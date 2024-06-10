import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:text_call/models/complex_message.dart';
import 'package:text_call/models/regular_message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/rich_message_editor.dart/preview_screen.dart';
import 'package:text_call/screens/rich_message_editor.dart/rich_message_editor_screen.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/dialogs/choose_color_dialog.dart';
import 'package:text_call/widgets/dialogs/confirm_dialog.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg_provider;

class MessageWriter extends ConsumerStatefulWidget {
  const MessageWriter({
    super.key,
    required this.calleePhoneNumber,
  });

  final String calleePhoneNumber;

  // these variables are going to be used when we want to recall a user via a recent message we already called them with before.
  // final String regularMessageForRecall;
  // final String complexMessageForRecall;

  @override
  ConsumerState<MessageWriter> createState() => _MessageWriterState();
}

class _MessageWriterState extends ConsumerState<MessageWriter> {
  final TextEditingController _messageController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(milliseconds: 800),
  );

  late String _recentId;
  late Future _animationDelay;
  late String _callerPhoneNumber;
  WebSocketChannel? _channel;
  bool _callSending = false;
  bool _filesUploading = false;
  Color _selectedColor = const Color.fromARGB(255, 13, 214, 214);
  final _animatedAcceptedTextColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  late Widget _messageWriterMessageBox;
  Map<String, dynamic>? _upToDateBolexyroJson;
  Map<String, dynamic>? _bolexyroJsonWithPermanentLocalUrlsAndOnlineUrls;
  final List<String> _lastCallMediaRemoteReferencesPath = [];

  bool _isMadeAvailableOffline = false;
  double _fileUploadProgress = 0;
  String _fileUploadText = '';
  late Future<String> _imageDirectoryPath;
  late Future<String> _videoDirectoryPath;
  late Future<String> _audioDirectoryPath;

  @override
  void initState() {
    _imageDirectoryPath =
        messagesDirectoryPath(isTemporary: false, specificDirectory: 'images');
    _videoDirectoryPath =
        messagesDirectoryPath(isTemporary: false, specificDirectory: 'videos');
    _audioDirectoryPath =
        messagesDirectoryPath(isTemporary: false, specificDirectory: 'audio');

    _messageWriterMessageBox = TextField(
      controller: _messageController,
      minLines: 4,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Enter the message you want to call them with',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelText: 'Message',
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _confettiController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _callSomeone(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _callerPhoneNumber = prefs.getString('myPhoneNumber')!;
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://text-call-backend.onrender.com/ws/$_callerPhoneNumber'),
    );

    // the delay before we assume call was not picked
    _animationDelay = Future.delayed(
      const Duration(seconds: 60),
    );

    _recentId = DateTime.now().toString();
    prefs.setString('recentId', _recentId);

    // final xyz = jsonEncode(upToDateBolexyroJson!);
    // print(xyz);

    if (_messageWriterMessageBox.runtimeType == FileUiPlaceHolder) {
      _bolexyroJsonWithPermanentLocalUrlsAndOnlineUrls =
          await _saveFilesLocallyAndRemoteAndEditBolexyroJsonToContainTheStorageUrls(
              _upToDateBolexyroJson!);
      print('updated is $_bolexyroJsonWithPermanentLocalUrlsAndOnlineUrls');
    }

    setState(() {
      _callSending = true;
    });

    // make sure the bolexyro json you are sending has local paths to be null for the medias
    _channel!.sink.add(
      json.encode(
        {
          'caller_phone_number': _callerPhoneNumber,
          'callee_phone_number': widget.calleePhoneNumber,
          'message_json_string':
              _messageWriterMessageBox.runtimeType == FileUiPlaceHolder
                  ? jsonEncode(_removeLocalUrlsFromBolexyroJson(
                      _bolexyroJsonWithPermanentLocalUrlsAndOnlineUrls!))
                  : RegularMessage(
                      messageString: _messageController.text,
                      backgroundColor: _selectedColor,
                    ).toJsonString,
          'my_message_type':
              _messageWriterMessageBox.runtimeType == FileUiPlaceHolder
                  ? 'complex'
                  : 'regular',
          'message_id': _recentId,
        },
      ),
    );
  }

  void _deleteRemoteFilesNotNeeded() async {
    // so the only time we want to delete remote files is if the callee, is not using text call.
    // Or sha when the server returns call_status: error. But if later you decide to put those calls in recents db, make sure to remove this delete function
    // to prevent problems.
    final storageRef = FirebaseStorage.instance.ref();
    for (final refPath in _lastCallMediaRemoteReferencesPath) {
      await storageRef.child(refPath).delete();
    }
    print('All unused remote files have been deleted');
  }

// this function would be used to set the local urls for the files to null. When we want to send the bolexyroJson to the callee
// through the websocket. Reason why is because we don't want the callee to access those paths on their device because it might not exist.

  Map<String, dynamic> _removeLocalUrlsFromBolexyroJson(
      final Map<String, dynamic> upToDateBolexyroJson) {
    final updatedBolexyroJson = jsonDecode(jsonEncode(upToDateBolexyroJson));

    for (final entry in updatedBolexyroJson.entries) {
      final mediaType = entry.value.keys.first;
      if (mediaType == 'document') {
        continue;
      }
      // mediatypepathstring would be imagepaths, videopaths, audiopaths
      final String mediaTypePathString = entry.value.values.first.keys.first;
      updatedBolexyroJson[entry.key][mediaType][mediaTypePathString]['local'] =
          null;
    }

    return updatedBolexyroJson;
  }

  Future<Map<String, dynamic>>
      _saveFilesLocallyAndRemoteAndEditBolexyroJsonToContainTheStorageUrls(
          Map<String, dynamic> upToDateBolexyroJson) async {
    setState(() {
      _filesUploading = true;
    });
    _lastCallMediaRemoteReferencesPath.clear();
    try {
      final imageDirectoryPath = await _imageDirectoryPath;
      final videoDirectoryPath = await _videoDirectoryPath;
      final audioDirectoryPath = await _audioDirectoryPath;
      final storageRef = FirebaseStorage.instance.ref();
      final imagesRef = storageRef.child('images');
      final audioRef = storageRef.child('audio');
      final videosRef = storageRef.child('videos');

      int currentImageIndex = 0;
      int currentVideoIndex = 0;
      int currentAudioIndex = 0;

      final updatedBolexyroJson = jsonDecode(jsonEncode(upToDateBolexyroJson));

      const uuid = Uuid();
      for (final entry in updatedBolexyroJson.entries) {
        final mediaType = entry.value.keys.first;
        if (mediaType == 'document') {
          continue;
        }

        // mediatypepathstring would be imagepaths, videopaths, audiopaths
        final String mediaTypePathString = entry.value.values.first.keys.first;
        final paths = entry.value.values.first.values.first;
        final localPath = paths['local'] as String;

        final localFile = File(localPath);
        String newFileName = '${uuid.v4()}${path.extension(localFile.path)}';

        late Reference mediaRef;

        switch (mediaType) {
          case 'image':
            mediaRef = imagesRef.child(newFileName);
            _fileUploadText = 'Uploading image ${++currentImageIndex}';

            break;
          case 'video':
            mediaRef = videosRef.child(newFileName);
            _fileUploadText = 'Uploading video ${++currentVideoIndex}';

            break;
          case 'audio':
            mediaRef = audioRef.child(newFileName);
            _fileUploadText = 'Uploading audio ${++currentAudioIndex}';

            break;
          default:
            continue;
        }

        if (_isMadeAvailableOffline) {
          storeFileInPermanentDirectory(
            sourceFile: localFile,
            fileName: newFileName,
            fileType: mediaType,
            imageDirectoryPath: imageDirectoryPath,
            videoDirectoryPath: videoDirectoryPath,
            audioDirectoryPath: audioDirectoryPath,
          ).then((permanentLocalFilePath) => updatedBolexyroJson[entry.key]
                  [mediaType][mediaTypePathString]['local'] =
              permanentLocalFilePath!);
        } else {
          updatedBolexyroJson[entry.key][mediaType][mediaTypePathString]
              ['local'] = null;
        }

        UploadTask uploadTask = mediaRef.putFile(localFile);
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = (snapshot.bytesTransferred.toDouble() /
                  snapshot.totalBytes.toDouble()) *
              100;
          setState(() {
            _fileUploadProgress = progress;
          });
        }, onError: (e) {
          print('Error is $e');
        });

        await uploadTask;
        _lastCallMediaRemoteReferencesPath.add(mediaRef.fullPath);
        final downloadUrl = await mediaRef.getDownloadURL();
        updatedBolexyroJson[entry.key][mediaType][mediaTypePathString]
            ['online'] = downloadUrl;
      }
      setState(() {
        _filesUploading = false;
      });
      return updatedBolexyroJson;
    } catch (e) {
      setState(() {
        _filesUploading = false;
      });
      print(e);
      throw 'File uplod Error';
    }
  }

  void _showColorPicker() async {
    FocusManager.instance.primaryFocus?.unfocus();

    Color? selectedColor = await showAdaptiveDialog(
      context: context,
      builder: (context) {
        return ChooseColorDialog(initialPickerColor: _selectedColor);
      },
    );

    if (selectedColor == null) {
      return;
    }
    setState(() {
      _selectedColor = selectedColor;
    });
  }

  void _updateMyOwnDocumentJson(Map<String, dynamic> newBolexyroJson) {
    _upToDateBolexyroJson = newBolexyroJson;
    setState(() {
      _messageWriterMessageBox = FileUiPlaceHolder(
        onBolexroJsonUpdated: _updateMyOwnDocumentJson,
        onDelete: _resetMessageWriterMessageBox,
        bolexyroJson: newBolexyroJson,
      );
    });
  }

  void _resetMessageWriterMessageBox() {
    _upToDateBolexyroJson = null;
    setState(() {
      _messageWriterMessageBox = TextField(
        controller: _messageController,
        minLines: 4,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Enter the message you want to call them with',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          labelText: 'Message',
        ),
      );
    });
  }

  bool _showDiscardDialog(Widget messageWriterContent) {
    return messageWriterContent.runtimeType != StreamBuilder &&
        (_messageWriterMessageBox.runtimeType == FileUiPlaceHolder ||
            (_messageWriterMessageBox.runtimeType == TextField &&
                _messageController.text.isNotEmpty));
  }

  @override
  Widget build(BuildContext context) {
    Widget messageWriterContent = Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            children: [
              _messageWriterMessageBox,
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _showColorPicker,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.color_lens,
                            color: _selectedColor // Icon color
                            ),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Color',
                          style: TextStyle(
                            color: _selectedColor, // Text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();

                          final Map<String, dynamic>? myOwnCustomDocumemntJson =
                              await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RichMessageEditorScreen(),
                            ),
                          );

                          if (myOwnCustomDocumemntJson != null) {
                            _updateMyOwnDocumentJson(myOwnCustomDocumemntJson);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/editor.svg',
                              height: kIconHeight,
                              colorFilter: ColorFilter.mode(
                                  _selectedColor, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Complex Editor?',
                              style: TextStyle(
                                color: _selectedColor, // Text color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              IconButton(
                onPressed: () async {
                  // if (await checkForInternetConnection(context)) {
                  _callSomeone(context);
                  // }
                },
                icon: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.phone,
                    size: 35,
                  ),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (_callSending) {
      int index = 0;
      messageWriterContent = StreamBuilder(
        stream: _channel!.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            index++;
            final snapshotData = json.decode(snapshot.data);
            print(snapshotData);
            if (snapshotData['call_status'] == 'error') {
              _channel?.sink.close();
              if (index == 1) {
                _deleteRemoteFilesNotNeeded();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Stack(
                  children: [
                    Lottie.asset(
                      'assets/animations/404 user not found.json',
                      height: 300,
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(() {
                                _callSending = false;
                              }),
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'The recipient\'s device could not be reached because the person was most likely a user of Text Call but is no longer a user of Text Call. Your message has been saved offline. Please verify the recipient\'s contact details or try again later.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pacifico(
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            if (snapshotData['call_status'] == 'ignored') {
              final recent = Recent.withoutContactObject(
                category: RecentCategory.outgoingIgnored,
                regularMessage: _upToDateBolexyroJson == null
                    ? RegularMessage(
                        messageString: _messageController.text,
                        backgroundColor: _selectedColor,
                      )
                    : null,
                complexMessage: _upToDateBolexyroJson == null
                    ? null
                    : ComplexMessage(
                        complexMessageJsonString: jsonEncode(
                            _bolexyroJsonWithPermanentLocalUrlsAndOnlineUrls!),
                      ),
                id: _recentId,
                phoneNumber: widget.calleePhoneNumber,
                callTime: DateTime.parse(_recentId),
              );
              if (index == 1) {
                ref.read(recentsProvider.notifier).addRecent(recent);
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 5),
                        child: IconButton(
                          onPressed: () => setState(() {
                            _callSending = false;
                            _channel?.sink.close();
                          }),
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'Alas, thy call was ignored.',
                        textAlign: TextAlign.center,
                        textStyle: GoogleFonts.pacifico(
                            fontSize: 32,
                            color: const Color.fromARGB(255, 139, 105, 2)),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    displayFullTextOnTap: true,
                    repeatForever: false,
                    totalRepeatCount: 1,
                  ),
                  Lottie.asset('assets/animations/call_missed.json'),
                ],
              );
            }
            if (snapshotData['call_status'] == 'rejected') {
              _channel?.sink.close();

              final recent = Recent.withoutContactObject(
                category: RecentCategory.outgoingRejected,
                regularMessage: _upToDateBolexyroJson == null
                    ? RegularMessage(
                        messageString: _messageController.text,
                        backgroundColor: _selectedColor,
                      )
                    : null,
                complexMessage: _upToDateBolexyroJson == null
                    ? null
                    : ComplexMessage(
                        complexMessageJsonString: jsonEncode(
                            _bolexyroJsonWithPermanentLocalUrlsAndOnlineUrls!),
                      ),
                id: _recentId,
                phoneNumber: widget.calleePhoneNumber,
                callTime: DateTime.parse(_recentId),
              );
              if (index == 1) {
                ref.read(recentsProvider.notifier).addRecent(recent);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 5),
                        child: IconButton(
                          onPressed: () => setState(() {
                            _callSending = false;
                          }),
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'Thy call hath been declined, leaving silence to linger in the void.',
                        textAlign: TextAlign.center,
                        textStyle: GoogleFonts.pacifico(
                            fontSize: 32,
                            color: const Color.fromARGB(255, 199, 32, 76)),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    displayFullTextOnTap: true,
                    repeatForever: false,
                    totalRepeatCount: 1,
                  ),
                  // Lottie.asset('assets/animations/call_rejected.json',
                  //     height: 300),
                ],
              );
            }
            if (snapshotData['call_status'] == 'accepted') {
              _channel?.sink.close();

              final recent = Recent.withoutContactObject(
                category: RecentCategory.outgoingAccepted,
                regularMessage: _upToDateBolexyroJson == null
                    ? RegularMessage(
                        messageString: _messageController.text,
                        backgroundColor: _selectedColor,
                      )
                    : null,
                complexMessage: _upToDateBolexyroJson == null
                    ? null
                    : ComplexMessage(
                        complexMessageJsonString: jsonEncode(
                            _bolexyroJsonWithPermanentLocalUrlsAndOnlineUrls!),
                      ),
                id: _recentId,
                phoneNumber: widget.calleePhoneNumber,
              );
              if (index == 1) {
                ref.read(recentsProvider.notifier).addRecent(recent);
              }
              _confettiController.play();
              return Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 5),
                        child: IconButton(
                          onPressed: () => setState(() {
                            _callSending = false;
                            _confettiController.stop();
                          }),
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Thy call hath been answered',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          fontFamily: 'Horizon',
                        ),
                        colors: _animatedAcceptedTextColors,
                      )
                    ],
                    displayFullTextOnTap: true,
                    repeatForever: true,
                  ),
                ],
              );
            }
            if (snapshotData['call_status'] == 'callee_busy') {
              _channel?.sink.close();
              return Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 5),
                        child: IconButton(
                          onPressed: () => setState(() {
                            _callSending = false;
                          }),
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'The number you are calling is receiving another call rn. Try again in less than 20 seconds',
                        textAlign: TextAlign.center,
                        textStyle: GoogleFonts.pacifico(
                            fontSize: 32,
                            color: const Color.fromARGB(255, 139, 105, 2)),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    displayFullTextOnTap: true,
                    repeatForever: false,
                    totalRepeatCount: 1,
                    onFinished: () {
                      Future.delayed(const Duration(seconds: 2), () {
                        if (_callSending) {
                          setState(() {
                            _callSending = false;
                          });
                        }
                      });
                    },
                  ),
                  Lottie.asset('assets/animations/call_missed.json'),
                ],
              );
            }
            return const Text(
                'This should be for some case that is not available yet');
          } else {
            return FutureBuilder(
              future: _animationDelay,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Lottie.asset(
                      'assets/animations/telephone_ringing_3d.json');
                }
                final recent = Recent.withoutContactObject(
                  category: RecentCategory.outgoingUnreachable,
                  regularMessage: _upToDateBolexyroJson == null
                      ? RegularMessage(
                          messageString: _messageController.text,
                          backgroundColor: _selectedColor,
                        )
                      : null,
                  complexMessage: _upToDateBolexyroJson == null
                      ? null
                      : ComplexMessage(
                          complexMessageJsonString: jsonEncode(
                              _bolexyroJsonWithPermanentLocalUrlsAndOnlineUrls!),
                        ),
                  id: _recentId,
                  phoneNumber: widget.calleePhoneNumber,
                );

                ref.read(recentsProvider.notifier).addRecent(recent);

                return Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 5),
                          child: IconButton(
                            onPressed: () => setState(() {
                              _callSending = false;
                              _channel?.sink.close();
                            }),
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          'Alas, the call remained unanswered.',
                          textAlign: TextAlign.center,
                          textStyle: GoogleFonts.pacifico(
                              fontSize: 32,
                              color: const Color.fromARGB(255, 139, 105, 2)),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      displayFullTextOnTap: true,
                      repeatForever: false,
                      totalRepeatCount: 1,
                    ),
                    Lottie.asset('assets/animations/call_missed.json'),
                  ],
                );
              },
            );
          }
        },
      );
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        if (_showDiscardDialog(messageWriterContent)) {
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
            messagesDirectoryPath(isTemporary: true, specificDirectory: null)
                .then(
              (tempMessagesDirectoryPath) =>
                  deleteDirectory(tempMessagesDirectoryPath),
            );
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              if (_showDiscardDialog(messageWriterContent)) {
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

                  messagesDirectoryPath(
                          isTemporary: true, specificDirectory: null)
                      .then(
                    (tempMessagesDirectoryPath) =>
                        deleteDirectory(tempMessagesDirectoryPath),
                  );
                } else {}
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              color: Colors.transparent,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.0),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_messageWriterMessageBox.runtimeType == FileUiPlaceHolder &&
                    !_callSending)
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Switch.adaptive(
                      activeColor: _selectedColor,
                      activeTrackColor: Theme.of(context).primaryColor,
                      inactiveTrackColor: Theme.of(context).primaryColor,
                      activeThumbImage: const svg_provider.Svg(
                        'assets/icons/make-available-offline.svg',
                        color: Colors.white,
                      ),
                      value: _isMadeAvailableOffline,
                      onChanged: (value) {
                        if (value) {
                          showFlushBar(
                            Colors.blue,
                            'Message is now available offline',
                            FlushbarPosition.TOP,
                            context,
                          );
                        }
                        setState(() {
                          _isMadeAvailableOffline = value;
                        });
                      },
                    ),
                  ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height * .6,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? makeColorLighter(Theme.of(context).primaryColor, 15)
                          : const Color.fromARGB(255, 207, 222, 234),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0,
                                MediaQuery.viewInsetsOf(context).vertical),
                            child: SingleChildScrollView(
                                child: messageWriterContent),
                          ),
                        ),
                        ConfettiWidget(
                          confettiController: _confettiController,
                          shouldLoop: true,
                          blastDirectionality: BlastDirectionality.explosive,
                          numberOfParticles: 30,
                          emissionFrequency: 0.1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_filesUploading)
            Positioned(
              bottom: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height * .6,
                  minWidth: MediaQuery.sizeOf(context).width,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * .8,
                          child: LinearProgressIndicator(
                            value: _fileUploadProgress / 100,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _fileUploadText,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FileUiPlaceHolder extends StatelessWidget {
  const FileUiPlaceHolder({
    super.key,
    required this.bolexyroJson,
    required this.onDelete,
    required this.onBolexroJsonUpdated,
  });
  final Map<String, dynamic> bolexyroJson;
  final void Function() onDelete;
  final void Function(Map<String, dynamic> newBolexyroJson)
      onBolexroJsonUpdated;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewScreen(
            bolexyroJson: bolexyroJson,
            forExtremePreview: true,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? makeColorLighter(Theme.of(context).primaryColor, 20)
              : const Color.fromARGB(255, 176, 208, 235),
          border: Border.all(width: 1),
        ),
        child: Center(
          child: Row(
            children: [
              const SizedBox(
                width: 29,
              ),
              SvgPicture.asset(
                'assets/icons/regular-file.svg',
                height: 40,
              ),
              const SizedBox(
                width: 20,
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Complex_Message.txtcall',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Click to view')
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  IconButton(
                    onPressed: () async {
                      final Map<String, dynamic>? newBolexyroJson =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RichMessageEditorScreen(
                            bolexyroJson: bolexyroJson,
                          ),
                        ),
                      );

                      if (newBolexyroJson != null) {
                        onBolexroJsonUpdated(newBolexyroJson);
                      }
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () async {
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
                        onDelete();
                      }
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/delete.svg',
                      colorFilter: const ColorFilter.mode(
                        Color.fromARGB(255, 255, 57, 43),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
