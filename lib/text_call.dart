import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/providers/blocked_contacts_provider.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/providers/received_access_requests_provider.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/auth_screen.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'package:text_call/screens/sent_message_screens/sms_from_terminated.dart';
import 'package:text_call/screens/splash_screen.dart';
import 'package:text_call/utils/constants.dart';

enum HowAppIsOPened {
  fromTerminatedToGrantOrDeyRequestAccess,
  fromTerminatedForPickedCall,
  appOpenedRegularly,
  // this one would be used when access has been granted and we only want to show
  fromTerminatedToShowMessageAfterAccessRequestGranted,
}

class TextCall extends ConsumerStatefulWidget {
  const TextCall({
    super.key,
    required this.howAppIsOPened,
    required this.themeMode,
    this.notificationPayload,
  });
  final HowAppIsOPened howAppIsOPened;
  final ThemeMode themeMode;
  final Map<String, dynamic>? notificationPayload;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  ConsumerState<TextCall> createState() => _TextCallState();
}

class _TextCallState extends ConsumerState<TextCall> {
  late Future<Map<String, dynamic>> _userInfo;

  Future<Map<String, dynamic>> getUserInfoAndLoadImportantStuff() async {
    await ref.read(contactsProvider.notifier).loadContacts();
    await ref.read(recentsProvider.notifier).loadRecents();
    await ref.read(blockedContactsProvider.notifier).loadBlockedContacts();
    await ref
        .read(receivedAccessRequestsProvider.notifier)
        .loadPendingReceivedAccessRequests(ref);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final bool? isUserLoggedIn = prefs.getBool('isUserLoggedIn');
    final String? callerPhoneNumber = prefs.getString('callerPhoneNumber');
    final String myPhoneNumber = prefs.getString('myPhoneNumber')!;
    return {
      'isUserLoggedIn': isUserLoggedIn,
      'callerPhoneNumber': callerPhoneNumber,
      'myPhoneNumber': myPhoneNumber,
    };
  }

  @override
  void initState() {
    _userInfo = getUserInfoAndLoadImportantStuff();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: widget.themeMode,
      theme: kLightTheme,
      darkTheme: kDarkTheme,
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
            if (widget.howAppIsOPened ==
                HowAppIsOPened.fromTerminatedForPickedCall) {
              final url = Uri.https(backendRootUrl,
                  'call/accepted/${userInfo['callerPhoneNumber']}');
              http.get(url);

              if (userInfo['isUserLoggedIn'] != true) {
                return const AuthScreen(
                  appOpenedFromPickedCall: true,
                );
              }
              return SmsFromTerminated(
                myPhoneNumber: userInfo['myPhoneNumber'],
                howSmsIsOpened: HowSmsIsOpened.fromTerminatedForPickCall,
              );
            }

            if (widget.howAppIsOPened ==
                HowAppIsOPened.fromTerminatedToGrantOrDeyRequestAccess) {
              if (userInfo['isUserLoggedIn'] != true) {
                return const AuthScreen(
                  appOpenedFromPickedCall: true,
                );
              }
              return SmsFromTerminated(
                myPhoneNumber: userInfo['myPhoneNumber'],
                notificationPayload: widget.notificationPayload,
                howSmsIsOpened:
                    HowSmsIsOpened.fromTerminatedToGrantOrDeyRequestAccess,
              );
            }

            if (widget.howAppIsOPened ==
                HowAppIsOPened
                    .fromTerminatedToShowMessageAfterAccessRequestGranted) {
              return SmsFromTerminated(
                myPhoneNumber: userInfo['myPhoneNumber'],
                notificationPayload: widget.notificationPayload,
                howSmsIsOpened: HowSmsIsOpened
                    .fromTerminatedToShowMessageAfterAccessRequestGranted,
              );
            }

            if (userInfo['isUserLoggedIn'] != true) {
              return const AuthScreen();
            }
            return PhonePageScreen(
              myPhoneNumber: userInfo['myPhoneNumber'],
            );
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
