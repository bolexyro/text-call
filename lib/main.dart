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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
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
          channelGroupName: 'App Interactions Group')
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
    ProviderScope(child: await whichTextCall(receivedAction)),
  );
}

Future<Widget> whichTextCall(ReceivedAction? receivedAction) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode');

  final ThemeMode themeMode = isDarkMode == null
      ? ThemeMode.system
      : isDarkMode == true
          ? ThemeMode.dark
          : ThemeMode.light;

  if (receivedAction == null) {
    return TextCall(
      themeMode: themeMode,
      howAppIsOPened: HowAppIsOPened.appOpenedRegularly,
    );
  }
  final currentCall = await getCurrentCall();
  if (currentCall != null) {
    return TextCall(
      themeMode: themeMode,
      howAppIsOPened: HowAppIsOPened.fromTerminatedForPickedCall,
    );
  }

  if (receivedAction.channelKey == 'access_requests_channel') {
    if (receivedAction.id.toString().startsWith('12')) {
      return TextCall(
        themeMode: themeMode,
        howAppIsOPened: HowAppIsOPened.fromTerminatedToShowMessage,
      );
    }
    return TextCall(
      themeMode: themeMode,
      howAppIsOPened: HowAppIsOPened.fromTerminatedForRequestAccess,
    );
  }

  return TextCall(
    themeMode: themeMode,
    howAppIsOPened: HowAppIsOPened.appOpenedRegularly,
  );
}

Future<dynamic> getCurrentCall() async {
  var calls = await FlutterCallkitIncoming.activeCalls();
  if (calls is List) {
    if (calls.isNotEmpty) {
      // final _currentUuid = calls[0]['id'];
      return calls[0];
    } else {
      // final _currentUuid = "";
      return null;
    }
  }
}
