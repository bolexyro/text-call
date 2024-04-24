import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/screens/auth_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

Future<void> _messageHandler(RemoteMessage message) async {
  late String callerName;
  final String callMessage = message.data['message'];
  final String callerPhoneNumber = message.data['caller_phone_number'];
  final Map<String, int> backgroundColorMap = {
    'red': int.parse(message.data['red']),
    'blue': int.parse(message.data['blue']),
    'green': int.parse(message.data['green']),
    'alpha': int.parse(message.data['alpha']),
  };

  final db = await getDatabase();
  final data = await db.query('contacts',
      where: 'phoneNumber = ?', whereArgs: [callerPhoneNumber]);

  if (data.isEmpty) {
    callerName = 'Unknown';
  } else {
    callerName = data[0]['name'] as String;
  }
  await db.close();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('callMessage', callMessage);
  await prefs.setString('callerPhoneNumber', callerPhoneNumber);
  await prefs.setString('callerName', callerPhoneNumber);
  await prefs.setString(
    'backgroundColor',
    json.encode(backgroundColorMap),
  );

  createAwesomeNotification(
    title: callerName != 'Unknown'
        ? '$callerName is calling '
        : '$callerPhoneNumber is calling',
    body: 'Might be urgent. Schrödinger\'s message',
  );
}

Future<void> _fcmSetup() async {
  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission();
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {
      await _messageHandler(message);
    },
  );
}

// From what I understand, the onBackgroudMessage handler is in a different isolate and thus has no access to the data from the main isolate.
// Hence everything is pretty much null.
// https://stackoverflow.com/questions/65664203/flutter-global-variable-becomes-null-when-app-is-in-background
// https://github.com/firebase/flutterfi  re/issues/1878
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await _messageHandler(message);
}

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
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color.fromARGB(255, 151, 73, 214),
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
    debug: true,
  );

  await _fcmSetup();
  FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod:
        NotificationController.onNotificationCreatedMethod,
    onNotificationDisplayedMethod:
        NotificationController.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod:
        NotificationController.onDismissActionReceivedMethod,
  );
  ReceivedAction? receivedAction =
      await AwesomeNotifications().getInitialNotificationAction(
    removeFromActionEvents: false,
  );
  runApp(
    ProviderScope(
      child: receivedAction == null
          ? const TextCall(fromTerminated: false)
          : const TextCall(fromTerminated: true),
    ),
  );
}

class TextCall extends StatefulWidget {
  const TextCall({
    super.key,
    required this.fromTerminated,
  });
  final bool fromTerminated;

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isUserLoggedIn = prefs.getBool('isUserLoggedIn');

    return isUserLoggedIn ?? false;
  }

  @override
  void initState() {
    _isUserLoggedIn = isUserLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.dark),
      ),
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
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.data!) {
            if (widget.fromTerminated) {
              return const SentMessageScreen(
                message: 'message',
                backgroundColor: Colors.red,
                fromTerminated: true,
              );
            }
            return const PhonePageScreen();
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
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'REJECT') {
      final prefs = await SharedPreferences.getInstance();
      final String? callerPhoneNumber = prefs.getString('callerPhoneNumber');

      final url = Uri.https(
          'text-call-backend.onrender.com', 'call/rejected/$callerPhoneNumber');
      http.get(url);
    }

    if (receivedAction.buttonKeyPressed == 'ACCEPT') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final String? callMessage = prefs.getString('callMessage');
      final String? callerPhoneNumber = prefs.getString('callerPhoneNumber');
      final String? callerName = prefs.getString('callerName');
      final String? backgroundColor = prefs.getString('backgroundColor');

      final url = Uri.https(
          'text-call-backend.onrender.com', 'call/accepted/$callerPhoneNumber');
      http.get(url);

      final db = await getDatabase();
      final newRecent = Recent(
        message: Message(
          message: callMessage!,
          backgroundColor: deJsonifyColor(json.decode(backgroundColor!)),
        ),
        contact: Contact(name: callerName!, phoneNumber: callerPhoneNumber!),
        category: RecentCategory.incomingAccepted,
      );

      db.insert(
        'recents',
        {
          'backgroundColorAlpha': newRecent.message.backgroundColor.alpha,
          'backgroundColorRed': newRecent.message.backgroundColor.red,
          'backgroundColorGreen': newRecent.message.backgroundColor.green,
          'backgroundColorBlue': newRecent.message.backgroundColor.blue,
          'message': newRecent.message.message,
          'callTime': newRecent.callTime.toString(),
          'phoneNumber': newRecent.contact.phoneNumber,
          'name': newRecent.contact.name,
          'categoryName': newRecent.category.name,
        },
      );
      await db.close();
      Navigator.of(TextCall.navigatorKey.currentContext!).push(
        MaterialPageRoute(
          builder: (context) => SentMessageScreen(
            backgroundColor: deJsonifyColor(json.decode(backgroundColor)),
            message: callMessage.isEmpty
                ? 'Bolexyro making innovations bro.'
                : callMessage,
          ),
        ),
      );
    }
  }
}
