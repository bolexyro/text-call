import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/complex_message.dart';
import 'package:text_call/models/regular_message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/floating_buttons_visible_provider.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'package:text_call/utils/utils.dart';

class SmsNotFromTerminated extends ConsumerWidget {
  const SmsNotFromTerminated({
    super.key,
    required this.message,
    required this.howSmsIsOpened,
  });

  // this message should not be null if howsmsisopened == notfromterminatedtoshow message
  final RegularMessage? message;
  final HowSmsIsOpened howSmsIsOpened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('regular message is ${message?.toJsonString}');
    return SafeArea(
      child: widgetToRenderBasedOnHowAppIsOpened(
        message: message,
        howSmsIsOpened: howSmsIsOpened,
        ref: ref,
        context: context,
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

  final RegularMessage message;
  final HowSmsIsOpened howSmsIsOpened;

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
          child: Center(
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
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: MyAnimatedTextWidget(message: widget.message),
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
                    sendAccessRequestStatus(AccessRequestStatus.granted);
                    if (widget.howSmsIsOpened ==
                        HowSmsIsOpened
                            .notFromTerminatedToGrantOrDeyRequestAccess) {
                      Navigator.of(context).pop();
                      return;
                    }

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
                    Navigator.of(context).pop();
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
              ],
            ),
          )
      ],
    );
  }
}

Widget widgetToRenderBasedOnHowAppIsOpened(
    {required HowSmsIsOpened howSmsIsOpened,
    required RegularMessage? message,
    required WidgetRef ref,
    required BuildContext context}) {
  // if (howSmsIsOpened ==
  //         HowSmsIsOpened
  //             .notFromTerminatedToShowMessageAfterAccessRequestGranted ||
  //     howSmsIsOpened ==
  //         HowSmsIsOpened.notFromTerminatedToGrantOrDeyRequestAccess ||
  //     howSmsIsOpened == HowSmsIsOpened.notFromTerminatedForPickedCall) {
  if (howSmsIsOpened == HowSmsIsOpened.notFromTerminatedForPickedCall) {
    final prefsFuture = SharedPreferences.getInstance();
    prefsFuture.then((prefs) {
      prefs.reload();

      final String? messageJsonString = prefs.getString('messageJsonString');
      final String? callerPhoneNumber = prefs.getString('callerPhoneNumber');
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
    });
  }
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new),
      ),
      iconTheme: IconThemeData(
        color: message!.backgroundColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white,
      ),
      forceMaterialTransparency: true,
      title: ScaffoldTitle(color: message.backgroundColor),
    ),
    body: TheStackWidget(
      howSmsIsOpened: howSmsIsOpened,
      message: message,
    ),
    backgroundColor: message.backgroundColor,
  );
  // }
}
