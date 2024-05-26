import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/providers/floating_buttons_visible_provider.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/models/message.dart';

// fromTerminatedToGrantOrDeyRequestAccess,
// fromTerminatedForPickCall,
// fromTerminatedToShowMessageAfterAccessRequestGranted,

class SmsFromTerminated extends ConsumerWidget {
  const SmsFromTerminated({
    super.key,
    required this.message,
    required this.howSmsIsOpened,
  });

  // this message should not be null if howsmsisopened == notfromterminatedtoshow message
  final Message? message;
  final HowSmsIsOpened howSmsIsOpened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: WidgetToRenderBasedOnHowAppIsOpened(
        message: message,
        howSmsIsOpened: howSmsIsOpened,
      ),
    );
  }
}

class TheStackWidget extends ConsumerStatefulWidget {
  const TheStackWidget({
    super.key,
    required this.message,
    required this.howSmsIsOpened,
  });

  final Message message;
  final HowSmsIsOpened howSmsIsOpened;

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
    final backgroundActualColor = widget.message.backgroundColor;
    bool floatingButtonsVisible = ref.watch(floatingButtonsVisibleProvider);

    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          child: Center(
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
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: MyAnimatedTextWidget(message: widget.message),
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
                    sendAccessRequestStatus(AccessRequestStatus.granted);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PhonePageScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor:
                        makeColorLighter(widget.message.backgroundColor, -10),
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
                    sendAccessRequestStatus(AccessRequestStatus.denied);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PhonePageScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor:
                        makeColorLighter(widget.message.backgroundColor, -10),
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
                      builder: (context) => const PhonePageScreen(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    shape: const CircleBorder(),
                    backgroundColor: makeColorLighter(backgroundActualColor, 5),
                  ),
                  child: Icon(
                    Icons.home,
                    color: backgroundActualColor.computeLuminance() > 0.5
                        ? Colors.black
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
    required this.message,
  });

  final HowSmsIsOpened howSmsIsOpened;
  final Message? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool floatingButtonsVisible =
        ref.watch(floatingButtonsVisibleProvider);
    if (howSmsIsOpened ==
            HowSmsIsOpened
                .fromTerminatedToShowMessageAfterAccessRequestGranted ||
        howSmsIsOpened ==
            HowSmsIsOpened.fromTerminatedToGrantOrDeyRequestAccess) {
      final prefsFuture = SharedPreferences.getInstance();

      return FutureBuilder(
        future: prefsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final prefs = snapshot.data;
          final String? recentId = prefs!.getString('recentId');

          final db = getDatabase();
          return FutureBuilder(
            future: db,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final data = snapshot.data!
                  .query('recents', where: 'id = ?', whereArgs: [recentId]);
              return FutureBuilder(
                future: data,
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
                  final Message message = Message(
                    message: data[0]['message'] as String,
                    backgroundColor: Color.fromARGB(
                      data[0]['backgroundColorAlpha'] as int,
                      data[0]['backgroundColorRed'] as int,
                      data[0]['backgroundColorGreen'] as int,
                      data[0]['backgroundColorBlue'] as int,
                    ),
                  );
                  return Scaffold(
                    floatingActionButton: howSmsIsOpened ==
                                HowSmsIsOpened
                                    .fromTerminatedToShowMessageAfterAccessRequestGranted &&
                            floatingButtonsVisible
                        ? FloatingActionButton(
                            onPressed: () =>
                                Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const PhonePageScreen(),
                              ),
                            ),
                            shape: const CircleBorder(),
                            backgroundColor:
                                makeColorLighter(message.backgroundColor, 5),
                            child: Icon(
                              Icons.home,
                              color:
                                  message.backgroundColor.computeLuminance() >
                                          0.5
                                      ? Colors.black
                                      : Colors.white,
                            ),
                          )
                        : null,
                    body: TheStackWidget(
                      howSmsIsOpened: howSmsIsOpened,
                      message: message,
                    ),
                    backgroundColor: message.backgroundColor,
                  );
                },
              );
            },
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

          final String? callMessage = prefs.getString('callMessage');
          final String? backgroundColor = prefs.getString('backgroundColor');
          final String? callerPhoneNumber =
              prefs.getString('callerPhoneNumber');
          final String? recentId = prefs.getString('recentId');

          final newRecent = Recent.withoutContactObject(
              category: RecentCategory.incomingAccepted,
              message: Message(
                message: callMessage!,
                backgroundColor: deJsonifyColor(json.decode(backgroundColor!)),
              ),
              id: recentId!,
              phoneNumber: callerPhoneNumber!);

          ref.read(recentsProvider.notifier).addRecent(newRecent);
          final backgroundActualColor =
              deJsonifyColor(json.decode(backgroundColor));
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              iconTheme: IconThemeData(
                color: backgroundActualColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
              forceMaterialTransparency: true,
              title: ScaffoldTitle(color: backgroundActualColor),
            ),
            floatingActionButton: howSmsIsOpened ==
                        HowSmsIsOpened.fromTerminatedForPickCall &&
                    floatingButtonsVisible
                ? FloatingActionButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const PhonePageScreen(),
                      ),
                    ),
                    shape: const CircleBorder(),
                    backgroundColor: makeColorLighter(backgroundActualColor, 5),
                    child: Icon(
                      Icons.home,
                      color: backgroundActualColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  )
                : null,
            backgroundColor: backgroundActualColor,
            body: TheStackWidget(
              howSmsIsOpened: howSmsIsOpened,
              message: Message(
                message: newRecent.message.message,
                backgroundColor: newRecent.message.backgroundColor,
              ),
            ),
          );
        },
      );
    }
  }
}
