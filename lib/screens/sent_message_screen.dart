import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/models/message.dart';
import 'package:text_call/models/contact.dart';
import 'package:http/http.dart' as http;

// sms = sent message screen
enum HowSmsIsOpened {
  fromTerminatedForRequestAccess,
  fromTerminatedForPickedCall,
  notfromTerminatedForRequestAccess,
  notFromTerminatedForPickedCall,
  notFromTerminatedToShowMessage,
}

class SentMessageScreen extends ConsumerWidget {
  const SentMessageScreen({
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
      child: widgetToRenderBasedOnHowAppIsOpened(
          message: message, howSmsIsOpened: howSmsIsOpened, ref: ref),
    );
  }
}

class TheColumnWidget extends StatelessWidget {
  const TheColumnWidget({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedTextKit(
        animatedTexts: [
          TyperAnimatedText(
            message.message,
            textAlign: TextAlign.center,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40,
              color: message.backgroundColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            ),
            speed: const Duration(milliseconds: 100),
          ),
        ],
        displayFullTextOnTap: true,
        repeatForever: false,
        totalRepeatCount: 1,
      ),
    );
  }
}

class TheStackWidget extends StatelessWidget {
  const TheStackWidget({
    super.key,
    required this.message,
    required this.howSmsIsOpened,
  });

  final Message message;
  final HowSmsIsOpened howSmsIsOpened;
  final Color backgroundActualColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TheColumnWidget(message: message),
        if (howSmsIsOpened == HowSmsIsOpened.fromTerminatedForRequestAccess ||
            howSmsIsOpened == HowSmsIsOpened.notfromTerminatedForRequestAccess)
          Positioned(
            width: MediaQuery.sizeOf(context).width,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    sendAccessRequestStatus(AccessRequestStatus.granted);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor:
                        makeColorLighter(message.backgroundColor, -10),
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
                        makeColorLighter(message.backgroundColor, -10),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
                if (howSmsIsOpened ==
                    HowSmsIsOpened.fromTerminatedForRequestAccess)
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const PhonePageScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor:
                          makeColorLighter(backgroundActualColor, 5),
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

Widget widgetToRenderBasedOnHowAppIsOpened(
    {required HowSmsIsOpened howSmsIsOpened,
    required Message? message,
    required WidgetRef ref}) {
  if (howSmsIsOpened == HowSmsIsOpened.notFromTerminatedToShowMessage  ||
      howSmsIsOpened == HowSmsIsOpened.notfromTerminatedForRequestAccess) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: message!.backgroundColor.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white,
        ),
        forceMaterialTransparency: true,
        title: scaffoldTitle(message.backgroundColor),
      ),
      body: TheStackWidget(
        howSmsIsOpened: howSmsIsOpened,
        message: message,
      ),
      backgroundColor: message.backgroundColor,
    );
  }

  if (howSmsIsOpened == HowSmsIsOpened.notFromTerminatedForPickedCall) {
    final prefs = SharedPreferences.getInstance();

    return FutureBuilder(
      future: prefs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('waiting');
        }

        if (snapshot.hasError) {
          return const Text('error');
        }
        final prefs = snapshot.data;
        final String? callMessage = prefs!.getString('callMessage');
        final String? backgroundColor = prefs.getString('backgroundColor');
        final Message message = Message(
          message: callMessage!,
          backgroundColor: deJsonifyColor(json.decode(backgroundColor!)),
        );
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: message.backgroundColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            ),
            forceMaterialTransparency: true,
            title: scaffoldTitle(message.backgroundColor),
          ),
          body: TheStackWidget(
            howSmsIsOpened: howSmsIsOpened,
            message: message,
          ),
          backgroundColor: message.backgroundColor,
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
        final String? callerName = prefs.getString('callerName');
        final String? callerPhoneNumber = prefs.getString('callerPhoneNumber');
        final String? recentId = prefs.getString('recentId');

        final url = Uri.https('text-call-backend.onrender.com',
            'call/accepted/$callerPhoneNumber');
        http.get(url);

        final newRecent = Recent(
          id: recentId!,
          message: Message(
            message: callMessage!,
            backgroundColor: deJsonifyColor(json.decode(backgroundColor!)),
          ),
          contact: Contact(name: callerName!, phoneNumber: callerPhoneNumber!),
          category: RecentCategory.incomingAccepted,
        );

        ref.read(recentsProvider.notifier).addRecent(newRecent);
        final backgroundActualColor =
            deJsonifyColor(json.decode(backgroundColor));
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: backgroundActualColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            ),
            forceMaterialTransparency: true,
            title: scaffoldTitle(backgroundActualColor),
          ),
          floatingActionButton: howSmsIsOpened ==
                  HowSmsIsOpened.fromTerminatedForPickedCall
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
                backgroundColor: newRecent.message.backgroundColor),
          ),
        );
      },
    );
  }
}

Widget scaffoldTitle(Color color) {
  return Text(
    'From your loved one or not hehe.',
    style: TextStyle(
        color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
  );
}
