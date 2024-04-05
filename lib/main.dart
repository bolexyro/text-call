import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:text_call/screens/contacts_screen.dart';
import 'package:text_call/screens/keypad_screen.dart';
import 'package:text_call/screens/recents_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'firebase_options.dart';

void main() async {
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
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const TextCall(),
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
  int _currentPageIndex = 0;

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
    _initialSetup();
    super.initState();
  }

  void _initialSetup() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    print(token);
    print('setup done');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('inside onmessage.listen');
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 123,
          channelKey: 'basic_channel',
          color: Colors.white,
          title: message.notification!.title,
          body: message.notification!.body,
          category: NotificationCategory.Call,
          fullScreenIntent: true,
          autoDismissible: false,
          wakeUpScreen: true,
          backgroundColor: Colors.orange,
          // timeoutAfter: const Duration(seconds: 10),
          // duration: Duration(seconds: 10),
        ),
        actionButtons: [
          NotificationActionButton(
              key: 'ACCEPT',
              label: 'Accept Call',
              color: Colors.green,
              autoDismissible: true,),
          NotificationActionButton(
              key: 'REJECT',
              label: 'Reject Call',
              color: Colors.red,
              autoDismissible: true,),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: TextCall.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentPageIndex,
          indicatorColor: Colors.green,
          onDestinationSelected: (int index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          height: 60,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.drag_indicator_sharp),
              label: 'keypad',
            ),
            NavigationDestination(
              icon: Badge(
                label: Text('3'),
                child: Icon(
                  Icons.recent_actors,
                ),
              ),
              label: 'Recents',
            ),
            NavigationDestination(
              icon: Icon(Icons.contacts),
              label: 'Contacts',
            ),
          ],
        ),
        body: [
          const KeypadScreen(),
          const RecentsScreen(),
          const ContactsScreen(),
        ][_currentPageIndex],
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
    print('notification action received');
    print(receivedAction.buttonKeyPressed);
    if (receivedAction.buttonKeyPressed == 'REJECT') {
      print('twas not accepted');
    } else if (receivedAction.buttonKeyPressed == 'ACCEPT') {
      Navigator.of(TextCall.navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (context) =>
               const SentMessageScreen(message: 'Bolexyro making innovations bro.'),
        ),
      );
    }

    // TextCll.navigatorKey.push
    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // TextCall.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
    //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
  }
}
