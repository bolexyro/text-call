import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/complex_message.dart';
import 'package:text_call/models/regular_message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/floating_buttons_visible_provider.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/rich_message_editor.dart/preview_screen_content.dart';
import 'package:text_call/widgets/sent_message_screen_widgets.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:uuid/uuid.dart';

class SmsNotFromTerminated extends ConsumerWidget {
  const SmsNotFromTerminated({
    super.key,
    required this.howSmsIsOpened,
    required this.regularMessage,
    required this.complexMessage,
    required this.recentCallTime,
    this.notificationPayload,
    required this.isRecentOutgoing,
  });

  // this messages should not be null if howsmsisopened == notFromTerminatedToShowMessageAfterAccessRequestGranted
  final HowSmsIsOpened howSmsIsOpened;
  final DateTime? recentCallTime;
  final RegularMessage? regularMessage;
  final ComplexMessage? complexMessage;
  final Map<String, dynamic>? notificationPayload;
  final bool isRecentOutgoing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WidgetToRenderBasedOnHowAppIsOpened(
      isRecentOutgoing: isRecentOutgoing,
      notificationPayload: notificationPayload,
      recentCallTime: recentCallTime,
      howSmsIsOpened: howSmsIsOpened,
      regularMessage: regularMessage,
      complexMessage: complexMessage,
    );
  }
}

class TheStackWidget extends ConsumerStatefulWidget {
  const TheStackWidget({
    super.key,
    required this.howSmsIsOpened,
    required this.regularMessage,
    required this.complexMessage,
    required this.notificationPayload,
  });

  final HowSmsIsOpened howSmsIsOpened;
  final RegularMessage? regularMessage;
  final ComplexMessage? complexMessage;
  final Map<String, dynamic>? notificationPayload;

  @override
  ConsumerState<TheStackWidget> createState() => _TheStackWidgetState();
}

class _TheStackWidgetState extends ConsumerState<TheStackWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    bool floatingButtonsVisible = ref.watch(floatingButtonsVisibleProvider);

    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is UserScrollNotification) {
                if (scrollNotification.direction == ScrollDirection.forward) {
                  ref
                      .read(floatingButtonsVisibleProvider.notifier)
                      .updateVisibility(true);
                } else if (scrollNotification.direction ==
                    ScrollDirection.reverse) {
                  ref
                      .read(floatingButtonsVisibleProvider.notifier)
                      .updateVisibility(false);
                }
              }
              return false;
            },
            child: widget.regularMessage == null
                ? PreviewScreenContent(
                    bolexyroJson: widget.complexMessage!.bolexyroJson,
                  )
                : Center(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child:
                          MyAnimatedTextWidget(message: widget.regularMessage!),
                    ),
                  ),
          ),
        ),
        if (widget.howSmsIsOpened ==
                HowSmsIsOpened.notFromTerminatedToGrantOrDeyRequestAccess &&
            floatingButtonsVisible)
          Positioned(
            width: MediaQuery.sizeOf(context).width,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    sendAccessRequestStatus(
                        accessRequestStatus: AccessRequestStatus.granted,
                        payload: widget.notificationPayload!);

                    Navigator.of(context).pop();
                    return;
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: widget.regularMessage == null
                        ? Colors.black
                        : makeColorLighter(
                            widget.regularMessage!.backgroundColor, -10),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    sendAccessRequestStatus(
                        accessRequestStatus: AccessRequestStatus.denied,
                        payload: widget.notificationPayload!);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: widget.regularMessage == null
                        ? Colors.black
                        : makeColorLighter(
                            widget.regularMessage!.backgroundColor, -10),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }
}

class WidgetToRenderBasedOnHowAppIsOpened extends ConsumerStatefulWidget {
  const WidgetToRenderBasedOnHowAppIsOpened({
    super.key,
    required this.howSmsIsOpened,
    required this.regularMessage,
    required this.complexMessage,
    required this.recentCallTime,
    required this.notificationPayload,
    this.isRecentOutgoing,
  });

  final RegularMessage? regularMessage;
  final ComplexMessage? complexMessage;
  final bool? isRecentOutgoing;
  final DateTime? recentCallTime;
  final HowSmsIsOpened howSmsIsOpened;
  final Map<String, dynamic>? notificationPayload;

  @override
  ConsumerState<WidgetToRenderBasedOnHowAppIsOpened> createState() =>
      _WidgetToRenderBasedOnHowAppIsOpenedState();
}

class _WidgetToRenderBasedOnHowAppIsOpenedState
    extends ConsumerState<WidgetToRenderBasedOnHowAppIsOpened> {
  bool _isBeingRemovedFromOffline = false;
  bool _isBeingMadeAvailableOffline = false;
  // this _isMessageAvailableOffline is going to be null if we are dealing with a regular message rather than a complex message
  bool? _isMessageAvailableOffline;

  // this would be non null only if (widget.howSmsIsOpened ==  HowSmsIsOpened.notFromTerminatedForPickedCall)
  late Future<Recent?> newRecentAddedToState;
  late ComplexMessage? complexMessage;

  @override
  initState() {
    newRecentAddedToState = _addRecentToState();
    if (widget.complexMessage != null) {
      _isMessageAvailableOffline =
          isMessageAvailableOffline(widget.complexMessage!.bolexyroJson);
    }
    print(widget.complexMessage?.bolexyroJson);
    complexMessage = widget.complexMessage;
    super.initState();
  }

  Future<Recent?> _addRecentToState() async {
    if (widget.howSmsIsOpened ==
        HowSmsIsOpened.notFromTerminatedForPickedCall) {
      final prefs = await SharedPreferences.getInstance();
      prefs.reload();

      final String? callerPhoneNumber = prefs.getString('callerPhoneNumber');
      final String? recentId = prefs.getString('recentId');

      final newRecent = Recent.withoutContactObject(
        category: RecentCategory.incomingAccepted,
        regularMessage: widget.regularMessage,
        complexMessage: widget.complexMessage,
        id: recentId!,
        phoneNumber: callerPhoneNumber!,
      );
      ref.read(recentsProvider.notifier).addRecent(newRecent);
      return newRecent;
    }
    return null;
  }

  Future<void> _removeFilesFromOffline(
      Map<String, dynamic> bolexyroJson) async {
    setState(() {
      _isBeingRemovedFromOffline = true;
    });
    final updatedBolexyroJson = jsonDecode(jsonEncode(bolexyroJson));

    for (final entry in updatedBolexyroJson.entries) {
      final mediaType = entry.value.keys.first;
      if (mediaType == 'document') {
        continue;
      }

      final paths = entry.value.values.first.values.first;
      print('paths is $paths');
      final localPath = paths['local'] as String;
      final String mediaTypePathString = entry.value.values.first.keys.first;

      await deleteFile(localPath);
      updatedBolexyroJson[entry.key][mediaType][mediaTypePathString]['local'] =
          null;
    }

    if (widget.howSmsIsOpened == HowSmsIsOpened.fromTerminatedForPickCall) {
      ref.read(recentsProvider.notifier).updateRecent(
            recentCallTime: (await newRecentAddedToState)!.callTime,
            complexMessageJsonString: jsonEncode(updatedBolexyroJson),
          );
    } else {
      ref.read(recentsProvider.notifier).updateRecent(
            recentCallTime: widget.recentCallTime!,
            complexMessageJsonString: jsonEncode(updatedBolexyroJson),
          );
    }
    setState(() {
      _isBeingRemovedFromOffline = false;
      _isMessageAvailableOffline = false;
      complexMessage = ComplexMessage(
          complexMessageJsonString: jsonEncode(updatedBolexyroJson));
    });
  }

  Future<void> _makeAvailableOffline(Map<String, dynamic> bolexyroJson) async {
    setState(() {
      _isBeingMadeAvailableOffline = true;
    });
    const uuid = Uuid();

    final updatedBolexyroJson = jsonDecode(jsonEncode(bolexyroJson));

    final imageDirectoryPath = await messagesDirectoryPath(
        isTemporary: false, specificDirectory: 'images');
    final videoDirectoryPath = await messagesDirectoryPath(
        isTemporary: false, specificDirectory: 'videos');
    final audioDirectoryPath = await messagesDirectoryPath(
        isTemporary: false, specificDirectory: 'audio');
    final tempDirectoryPath = (await getTemporaryDirectory()).path;
    for (final entry in updatedBolexyroJson.entries) {
      final mediaType = entry.value.keys.first;
      if (mediaType == 'document') {
        continue;
      }

      final paths = entry.value.values.first.values.first;
      final remotePath = paths['online'] as String;
      final String mediaTypePathString = entry.value.values.first.keys.first;

      final String fileExtension = mediaType == 'image'
          ? '.jpg'
          : mediaType == 'video'
              ? '.mp4'
              : '.m4a';
      // Extracts file type from the URL
      String newFileName = '${uuid.v4()}$fileExtension';
      String tempFilePath = '$tempDirectoryPath/$newFileName';

      File mediaFile = await downloadFileFromUrl(remotePath, tempFilePath);

      updatedBolexyroJson[entry.key][mediaType][mediaTypePathString]['local'] =
          await storeFileInPermanentDirectory(
        sourceFile: mediaFile,
        fileName: newFileName,
        fileType: mediaType,
        imageDirectoryPath: imageDirectoryPath,
        videoDirectoryPath: videoDirectoryPath,
        audioDirectoryPath: audioDirectoryPath,
      );
    }

    if (widget.howSmsIsOpened == HowSmsIsOpened.fromTerminatedForPickCall) {
      ref.read(recentsProvider.notifier).updateRecent(
            recentCallTime: (await newRecentAddedToState)!.callTime,
            complexMessageJsonString: jsonEncode(updatedBolexyroJson),
          );
    } else {
      ref.read(recentsProvider.notifier).updateRecent(
            recentCallTime: widget.recentCallTime!,
            complexMessageJsonString: jsonEncode(updatedBolexyroJson),
          );
    }
    setState(() {
      _isBeingMadeAvailableOffline = false;
      _isMessageAvailableOffline = true;
      complexMessage = ComplexMessage(
          complexMessageJsonString: jsonEncode(updatedBolexyroJson));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        iconTheme: widget.regularMessage != null
            ? IconThemeData(
                color:
                    widget.regularMessage!.backgroundColor.computeLuminance() >
                            0.5
                        ? Colors.black
                        : Colors.white,
              )
            : null,
        forceMaterialTransparency: true,
        actions: [
          if (_isMessageAvailableOffline != null &&
              !bolexyroJsonContainsOnlyRichText(complexMessage!.bolexyroJson))
            if (_isMessageAvailableOffline == false)
              _isBeingMadeAvailableOffline
                  ? const Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: SizedBox(
                        height: kIconHeight,
                        width: kIconHeight,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : IconButton(
                      onPressed: () =>
                          _makeAvailableOffline(complexMessage!.bolexyroJson),
                      icon: SvgPicture.asset(
                        'assets/icons/download.svg',
                        height: kIconHeight,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
          if (_isMessageAvailableOffline != null &&
              !bolexyroJsonContainsOnlyRichText(complexMessage!.bolexyroJson))
            if (_isMessageAvailableOffline == true)
              _isBeingRemovedFromOffline
                  ? const CircularProgressIndicator()
                  : IconButton(
                      onPressed: () =>
                          _removeFilesFromOffline(complexMessage!.bolexyroJson),
                      icon: SvgPicture.asset(
                        'assets/icons/delete.svg',
                        height: kIconHeight,
                        colorFilter: const ColorFilter.mode(
                          Colors.red,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
        ],
        title: ScaffoldTitle(
          color: widget.regularMessage?.backgroundColor ??
              Theme.of(context).scaffoldBackgroundColor,
          isOutgoing: widget.isRecentOutgoing ?? true,
        ),
      ),
      body: SafeArea(
        child: TheStackWidget(
          notificationPayload: widget.notificationPayload,
          howSmsIsOpened: widget.howSmsIsOpened,
          regularMessage: widget.regularMessage,
          complexMessage: widget.complexMessage,
        ),
      ),
      backgroundColor: widget.regularMessage?.backgroundColor,
    );
    // }
  }
}
