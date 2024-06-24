import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/complex_message.dart';
import 'package:text_call/providers/floating_buttons_visible_provider.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/screens/rich_message_editor.dart/preview_screen_content.dart';
import 'package:text_call/widgets/sent_message_screen_widgets.dart';
import 'package:text_call/utils/crud.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/models/regular_message.dart';

// fromTerminatedToGrantOrDeyRequestAccess,
// fromTerminatedForPickCall,
// fromTerminatedToShowMessageAfterAccessRequestGranted,

class SmsFromTerminated extends ConsumerWidget {
  const SmsFromTerminated({
    super.key,
    required this.howSmsIsOpened,
    this.notificationPayload,
    required this.myPhoneNumber,
  });

  // this message should not be null if howsmsisopened == notfromterminatedtoshow message
  final HowSmsIsOpened howSmsIsOpened;
  final Map<String, dynamic>? notificationPayload;
  final String myPhoneNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: WidgetToRenderBasedOnHowAppIsOpened(
        myPhoneNumber: myPhoneNumber,
        howSmsIsOpened: howSmsIsOpened,
        notificationPayload: notificationPayload,
      ),
    );
  }
}

class TheStackWidget extends ConsumerStatefulWidget {
  const TheStackWidget({
    super.key,
    required this.howSmsIsOpened,
    required this.regularMessage,
    required this.complexMessage,
    required this.myPhoneNumber,
    this.notificationPayload,
  });

  final HowSmsIsOpened howSmsIsOpened;
  final RegularMessage? regularMessage;
  final ComplexMessage? complexMessage;
  final Map<String, dynamic>? notificationPayload;
  final String myPhoneNumber;

  @override
  ConsumerState<TheStackWidget> createState() => _TheStackWidgetState();
}

class _TheStackWidgetState extends ConsumerState<TheStackWidget> {
  // buttonw will be visible when the screen is displayed at first.
  // and they'll also be visible when we are scrolling up
  // they'd be !visible when we are scrolling down.

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
                      .updateVisibility(false);
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
                    bolexyroJson: widget.complexMessage!.bolexyroJson)
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
                HowSmsIsOpened.fromTerminatedToGrantOrDeyRequestAccess &&
            floatingButtonsVisible)
          Positioned(
            width: MediaQuery.sizeOf(context).width,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    deleteAccessRequestFromDb(
                        recentId: widget.notificationPayload!['recentId']!);

                    sendAccessRequestStatus(
                        accessRequestStatus: AccessRequestStatus.granted,
                        payload: widget.notificationPayload!);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhonePageScreen(
                          myPhoneNumber: widget.myPhoneNumber,
                        ),
                      ),
                    );
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
                    deleteAccessRequestFromDb(
                        recentId: widget.notificationPayload!['recentId']!);

                    sendAccessRequestStatus(
                        accessRequestStatus: AccessRequestStatus.denied,
                        payload: widget.notificationPayload!);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhonePageScreen(
                            myPhoneNumber: widget.myPhoneNumber),
                      ),
                    );
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
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          PhonePageScreen(myPhoneNumber: widget.myPhoneNumber),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    shape: const CircleBorder(),
                    backgroundColor: widget.regularMessage == null
                        ? Colors.black
                        : makeColorLighter(
                            widget.regularMessage!.backgroundColor, 5),
                  ),
                  child: Icon(
                    Icons.home,
                    color: widget.regularMessage != null
                        ? widget.regularMessage!.backgroundColor
                                    .computeLuminance() >
                                0.5
                            ? Colors.black
                            : Colors.white
                        : Colors.white,
                  ),
                )
              ],
            ),
          )
      ],
    );
  }
}

class WidgetToRenderBasedOnHowAppIsOpened extends ConsumerWidget {
  const WidgetToRenderBasedOnHowAppIsOpened({
    super.key,
    required this.howSmsIsOpened,
    this.notificationPayload,
    required this.myPhoneNumber,
  });

  final Map<String, dynamic>? notificationPayload;
  final String myPhoneNumber;

  final HowSmsIsOpened howSmsIsOpened;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool floatingButtonsVisible =
        ref.watch(floatingButtonsVisibleProvider);
    if (howSmsIsOpened ==
            HowSmsIsOpened
                .fromTerminatedToShowMessageAfterAccessRequestGranted ||
        howSmsIsOpened ==
            HowSmsIsOpened.fromTerminatedToGrantOrDeyRequestAccess) {
      final dataFuture =
          readRecentsFromDb(whereId: notificationPayload!['recentId']!);
      return FutureBuilder(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final data = snapshot.data!;

          final regularMessage = data[0]['messageType'] == 'regular'
              ? RegularMessage.fromJsonString(
                  data[0]['messageJson'] as String,
                )
              : null;
          final complexMessage = data[0]['messageType'] == 'complex'
              ? ComplexMessage(
                  complexMessageJsonString: data[0]['messageJson'] as String,
                )
              : null;

          return Scaffold(
            floatingActionButton: howSmsIsOpened ==
                        HowSmsIsOpened
                            .fromTerminatedToShowMessageAfterAccessRequestGranted &&
                    floatingButtonsVisible
                ? FloatingActionButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            PhonePageScreen(myPhoneNumber: myPhoneNumber),
                      ),
                    ),
                    shape: const CircleBorder(),
                    backgroundColor: regularMessage == null
                        ? Colors.black
                        : makeColorLighter(regularMessage.backgroundColor, 5),
                    child: Icon(
                      Icons.home,
                      color: regularMessage == null
                          ? Colors.white
                          : regularMessage.backgroundColor.computeLuminance() >
                                  0.5
                              ? Colors.black
                              : Colors.white,
                    ),
                  )
                : null,
            body: TheStackWidget(
              myPhoneNumber: myPhoneNumber,
              howSmsIsOpened: howSmsIsOpened,
              regularMessage: regularMessage,
              complexMessage: complexMessage,
              notificationPayload: notificationPayload,
            ),
            backgroundColor: regularMessage?.backgroundColor,
          );
        },
      );
    } else {
      final prefs = SharedPreferences.getInstance();

      return FutureBuilder(
        future: prefs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error ${snapshot.error}'),
            );
          }
          final prefs = snapshot.data;
          prefs!.reload();

          final String? messageJsonString =
              prefs.getString('messageJsonString');
          final String? callerPhoneNumber =
              prefs.getString('callerPhoneNumber');
          final String? recentId = prefs.getString('recentId');
          final String? messageType = prefs.getString('messageType');

          final newRecent = Recent.withoutContactObject(
            category: RecentCategory.incomingAccepted,
            regularMessage: messageType == 'regular'
                ? RegularMessage.fromJsonString(messageJsonString!)
                : null,
            complexMessage: messageType == 'complex'
                ? ComplexMessage(complexMessageJsonString: messageJsonString!)
                : null,
            id: recentId!,
            phoneNumber: callerPhoneNumber!,
          );

          ref.read(recentsProvider.notifier).addRecent(newRecent);

          return Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
              title: ScaffoldTitle(
                color: newRecent.regularMessage?.backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                isOutgoing: false,
              ),
            ),
            floatingActionButton:
                howSmsIsOpened == HowSmsIsOpened.fromTerminatedForPickCall &&
                        floatingButtonsVisible
                    ? FloatingActionButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                PhonePageScreen(myPhoneNumber: myPhoneNumber),
                          ),
                        ),
                        shape: const CircleBorder(),
                        backgroundColor: newRecent.regularMessage == null
                            ? Colors.black
                            : makeColorLighter(
                                newRecent.regularMessage!.backgroundColor,
                                5,
                              ),
                        child: Icon(
                          Icons.home,
                          color: newRecent.regularMessage == null
                              ? Colors.white
                              : newRecent.regularMessage!.backgroundColor
                                          .computeLuminance() >
                                      0.5
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      )
                    : null,
            backgroundColor: newRecent.regularMessage?.backgroundColor,
            body: TheStackWidget(
              myPhoneNumber: myPhoneNumber,
              notificationPayload: notificationPayload,
              howSmsIsOpened: howSmsIsOpened,
              regularMessage: newRecent.regularMessage,
              complexMessage: newRecent.complexMessage,
            ),
          );
        },
      );
    }
  }
}
