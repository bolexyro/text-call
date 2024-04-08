import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/screens/auth_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'package:text_call/utils/create_awesome_notification.dart';
import 'firebase_options.dart';

String? kToken;
String? kCallMessage;

Future<void> _fcmSetup() async {
  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission();
  kToken = await fcm.getToken();
  print('Token is $kToken');
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {
      kCallMessage = message.data['message'];
      print('message received');
      createAwesomeNotification(
          title: message.notification!.title, body: message.notification!.body);
    },
  );
}

@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  createAwesomeNotification(
      title: message.notification!.title, body: message.notification!.body);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          locked: true,
          channelShowBadge: true,
          importance: NotificationImportance.Max,
        )
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);
  await _fcmSetup();
  FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  runApp(
    const ProviderScope(child: TextCall()),
  );
}

class TextCall extends StatefulWidget {
  const TextCall({super.key});
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String name = 'Awesome Notifications - Example App';
  static const Color mainColor = Colors.deepPurple;

  @override
  State<TextCall> createState() => _TextCallState();
}

class _TextCallState extends State<TextCall> {
  late Future<bool> _isUserLoggedIn;

  Future<bool> isUserLoggedIn() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isUserLoggedIn = prefs.getBool('isUserLoggedIn');

    // Save an boolean value to 'repeat' key.
    return isUserLoggedIn ?? false;
  }

  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
    _isUserLoggedIn = isUserLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: TextCall.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _isUserLoggedIn,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return const PhonePageScreen();
            }
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    print('notification created');
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
    print('notification displayed');
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
    print('notification dismissed');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
    if (receivedAction.buttonKeyPressed == 'REJECT') {
      return;
    } else if (receivedAction.buttonKeyPressed == 'ACCEPT') {
      Navigator.of(TextCall.navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => SentMessageScreen(
              message: kCallMessage == null|| kCallMessage!.isEmpty
                  ? 'Bolexyro making innovations bro.'
                  : kCallMessage!),
        ),
      );
    }
  }
}
