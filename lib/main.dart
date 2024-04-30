import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:text_call/screens/sent_message_screen.dart';
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
    ProviderScope(
      child: whichTextCall(receivedAction)
    ),
  );
}

Widget whichTextCall(ReceivedAction? receivedAction) {
  if (receivedAction?.buttonKeyPressed == 'ACCEPT_CALL') {
        return const TextCall(howAppIsOPened: HowAppIsOPened.fromTerminatedNotForPickedCall);

  //   return const TextCall(
  //       appOpenedForAccessRequest: false,
  //       appOpenedFromPickedCallOrTappedNotification: true);
  // }

  // if the notification is tapped
  if (receivedAction?.channelKey == 'access_requests_channel') {
    return const TextCall(
      appOpenedForAccessRequest: true,
      appOpenedFromPickedCallOrTappedNotification: true,
    );
  }

  return const TextCall(
      appOpenedForAccessRequest: false,
      appOpenedFromPickedCallOrTappedNotification: false);
}
