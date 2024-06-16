import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/text_call.dart';
import 'package:text_call/utils/notification_services.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final lastCallTime = await getLastCall();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app ic on
    null,
    [
      NotificationChannel(
        channelGroupKey: 'app_interactions_group',
        channelKey: 'calls_channel',
        channelName: 'Call Notifications',
        channelDescription: 'Notification channel for calls',
        defaultColor: Colors.blue,
        ledColor: Colors.blue,
        defaultRingtoneType: DefaultRingtoneType.Ringtone,
        locked: true,
        channelShowBadge: true,
        importance: NotificationImportance.Max,
      ),
      NotificationChannel(
        channelKey: 'access_requests_channel',
        channelName: 'Access Requests',
        channelDescription: 'Notification channel for access requests',
        defaultColor: Colors.blue,
        ledColor: Colors.blue,
        importance: NotificationImportance.Low,
        onlyAlertOnce: true,
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'app_interactions_group',
        channelGroupName: 'App Interactions Group',
      )
    ],
    debug: true,
  );

  await fcmSetup();
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
  ReceivedAction? receivedAction =
      await AwesomeNotifications().getInitialNotificationAction(
    removeFromActionEvents: true,
  );
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod:
        NotificationController.onNotificationCreatedMethod,
    onNotificationDisplayedMethod:
        NotificationController.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod:
        NotificationController.onDismissActionReceivedMethod,
  );
  runApp(
    ProviderScope(
      child: await whichTextCall(receivedAction, lastCallTime),
    ),
  );
}

Future<Widget> whichTextCall(
    ReceivedAction? receivedAction, dynamic lastCallTime) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode');

  final ThemeMode themeMode = isDarkMode == null
      ? ThemeMode.dark
      : isDarkMode == true
          ? ThemeMode.dark
          : ThemeMode.light;

  if (lastCallTime != null) {
    return TextCall(
      howAppIsOPened: HowAppIsOPened.fromTerminatedForPickedCall,
      themeMode: themeMode,
    );
  }

  if (receivedAction == null) {
    return TextCall(
      themeMode: themeMode,
      howAppIsOPened: HowAppIsOPened.appOpenedRegularly,
    );
  }

  if (receivedAction.channelKey == 'access_requests_channel') {
    if (receivedAction.id.toString().startsWith('12')) {
      return TextCall(
        themeMode: themeMode,
        howAppIsOPened: HowAppIsOPened.fromTerminatedToShowMessageAfterAccessRequestGranted,
        notificationPayload: receivedAction.payload,
      );
    }
    return TextCall(
      themeMode: themeMode,
      howAppIsOPened: HowAppIsOPened.fromTerminatedForRequestAccess,
      notificationPayload: receivedAction.payload,
    );
  }

  return TextCall(
    themeMode: themeMode,
    howAppIsOPened: HowAppIsOPened.appOpenedRegularly,
  );
}

Future<dynamic> getLastCall() async {
  final calls = await FlutterCallkitIncoming.activeCalls();
  if (calls is List) {
    if (calls.isNotEmpty) {
      final lastCall = calls[calls.length - 1];

      // 20 is the number of seconds before a call ends. so if we pick a call before that time ends,
      // we return a non null object
      // because activeCAlls gives us a list of all the calls that has been accepted. so we get the last one and check its time which is its id

      //i made the 20 21 because of the await. lets just assume it takes 1 second
      if (DateTime.now().difference(DateTime.parse(lastCall['id'])).inSeconds <=
              21 &&
          lastCall['isAccepted']) {
        return lastCall['id'];
      }
    } else {
      return null;
    }
  }
}
