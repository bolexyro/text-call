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

enum HowAppIsOPened {
  fromTerminatedForRequestAccess,
  fromTerminatedForPickedCall,
  notfromTerminatedForRequestAccess,
  notFromTerminatedForPickedCall,
}

class SentMessageScreen extends ConsumerWidget {
  const SentMessageScreen({
    super.key,
    this.message,
    required this.howAppIsOpened,
  });

  final Message? message;
  final HowAppIsOPened howAppIsOpened;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
        child: widgetToRenderBasedOnHowAppIsOpened(
            howAppIsOpened: howAppIsOpened, ref: ref));
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
    required this.howAppIsOpened,
  });

  final Message message;
  final HowAppIsOPened howAppIsOpened;
  final Color backgroundActualColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TheColumnWidget(message: message),
        if (howAppIsOpened == HowAppIsOPened.fromTerminatedForRequestAccess ||
            howAppIsOpened ==
                HowAppIsOPened.fromTerminatedForPickedCall ||
            howAppIsOpened == HowAppIsOPened.notfromTerminatedForRequestAccess)

        if (howAppIsOpened == HowAppIsOPened.fromTerminatedForRequestAccess || howAppIsOpened == HowAppIsOPened.notfromTerminatedForRequestAccess)
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
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const PhonePageScreen(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
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

Widget widgetToRenderBasedOnHowAppIsOpened(
    {required HowAppIsOPened howAppIsOpened,
    Message? message,
    required WidgetRef ref}) {
  if (howAppIsOpened == HowAppIsOPened.notFromTerminatedForPickedCall ||
      howAppIsOpened == HowAppIsOPened.notfromTerminatedForRequestAccess) {
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
        howAppIsOpened: howAppIsOpened,
        message: Message(
            message: message.message, backgroundColor: message.backgroundColor),
      ),
      backgroundColor: message.backgroundColor,
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
            floatingActionButton: howAppIsOpened ==
                    HowAppIsOPened.fromTerminatedForPickedCall
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
              howAppIsOpened: howAppIsOpened,
              message: Message(
                  message: message!.message,
                  backgroundColor: message.backgroundColor),
            ));
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
