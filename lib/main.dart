import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/screens/auth_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'package:text_call/screens/splash_screen.dart';
import 'package:text_call/utils/notification_services.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

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
        importance: NotificationImportance.Default,
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
      child: receivedAction == null
          ? const TextCall(appOpenedFromPickedCall: false)
          : const TextCall(appOpenedFromPickedCall: true),
    ),
  );
}

class TextCall extends StatefulWidget {
  const TextCall({
    super.key,
    required this.appOpenedFromPickedCall,
  });
  final bool appOpenedFromPickedCall;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<TextCall> createState() => _TextCallState();
}

class _TextCallState extends State<TextCall> {
  late Future<Map<String, dynamic>> _userInfo;

  Future<Map<String, dynamic>> userInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final bool? isUserLoggedIn = prefs.getBool('isUserLoggedIn');
    final String? callerPhoneNumber = prefs.getString('callerPhoneNumber');

    return {
      'isUserLoggedIn': isUserLoggedIn,
      'callerPhoneNumber': callerPhoneNumber,
    };
  }

  @override
  void initState() {
    _userInfo = userInfo();
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
        future: _userInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            final userInfo = snapshot.data!;
            if (widget.appOpenedFromPickedCall) {
              final url = Uri.https('text-call-backend.onrender.com',
                  'call/accepted/${userInfo['callerPhoneNumber']}');
              http.get(url);

              if (userInfo['isUserLoggedIn'] != true) {
                return const AuthScreen(
                  appOpenedFromPickedCall: true,
                );
              }
              return const SentMessageScreen(
                fromTerminated: true,
              );
            }

            if (userInfo['isUserLoggedIn'] != true) {
              return const AuthScreen();
            }
            return const PhonePageScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}