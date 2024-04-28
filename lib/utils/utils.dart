import 'package:another_flushbar/flushbar.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/widgets/contacts_screen_widgets/add_contact.dart';
import 'package:text_call/widgets/message_writer.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

enum Screen { phone, tablet }

enum NotificationPurpose { forCall, forAccessRequest }

void createAwesomeNotification(
    {String? title,
    String? body,
    required NotificationPurpose notificationPurpose}) {
  final DateTime currentDate = DateTime.now();

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      // the id is used to identify each notification. So if you have a static id like 123, when a new notification comes in, the old one goes out.
      id: int.parse(
          '11${currentDate.day}${currentDate.hour}${currentDate.minute}${currentDate.second}'),
      channelKey: notificationPurpose == NotificationPurpose.forCall
          ? 'calls_channel'
          : 'access_requests_channel',
      color: Colors.black,
      title: title,
      body: body,
      autoDismissible:
          notificationPurpose == NotificationPurpose.forCall ? false : true,
      category: NotificationCategory.Call,
      fullScreenIntent: true,
      wakeUpScreen: true,
      backgroundColor: Colors.green,
      locked: notificationPurpose == NotificationPurpose.forCall ? true : false,
      chronometer: notificationPurpose == NotificationPurpose.forCall
          ? Duration.zero
          : null, // Chronometer starts to count at 0 seconds
      timeoutAfter: notificationPurpose == NotificationPurpose.forCall
          ? const Duration(seconds: 20)
          : null,
    ),
    actionButtons: notificationPurpose == NotificationPurpose.forCall
        ? [
            NotificationActionButton(
              key: 'ACCEPT_CALL',
              label: 'Accept Call',
              color: Colors.green,
              autoDismissible: true,
            ),
            NotificationActionButton(
              key: 'REJECT_CALL',
              label: 'Reject Call',
              color: Colors.red,
              autoDismissible: true,
              actionType: ActionType.SilentAction,
            ),
          ]
        : [
            NotificationActionButton(
              key: 'GRANT_ACCESS',
              label: 'Grant Access',
              color: Colors.green,
              autoDismissible: true,
              actionType: ActionType.SilentAction,
            ),
            NotificationActionButton(
              key: 'DENY_ACCESS',
              label: 'Deny Access',
              color: Colors.red,
              autoDismissible: true,
              actionType: ActionType.SilentAction,
            ),
          ],
  );
}

String changeLocalToIntl({required String localPhoneNumber}) =>
    '+234${localPhoneNumber.substring(1)}';

String changeIntlToLocal({required String intlPhoneNumber}) =>
    '0${intlPhoneNumber.substring(4)}';

Future<bool> checkForInternetConnection() async {
  return await InternetConnection().hasInternetAccess;
}

Future<void> showMessageWriterModalSheet(
    {required BuildContext context,
    required String calleeName,
    required String calleePhoneNumber}) async {
  if (!await checkForInternetConnection()) {
    showErrorDialog('Connect to the internet and try again.', context);
    return;
  }
  showModalBottomSheet(
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (ctx) => MessageWriter(
      calleePhoneNumber: calleePhoneNumber,
    ),
  );
}

Future<sql.Database> getDatabase() async {
  final databasesPath = await sql.getDatabasesPath();

  final db = await sql.openDatabase(
    path.join(databasesPath, 'contacts.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE contacts (phoneNumber TEXT PRIMARY KEY, name TEXT)');
      await db.execute(
          'CREATE TABLE recents ( id TEXT PRIMARY KEY, callTime TEXT, phoneNumber TEXT, name TEXT, categoryName TEXT, message TEXT, backgroundColorRed INTEGER, backgroundColorGreen INTEGER, backgroundColorBlue INTEGER, backgroundColorAlpha INTEGER)');
    },
  );
  return db;
}

void showAddContactDialog(context, {String? phoneNumber}) async {
  showAdaptiveDialog(
    context: context,
    builder: (context) {
      return AddContact(phoneNumber: phoneNumber);
    },
  );
}

void showErrorDialog(String text, BuildContext context) async {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      backgroundColor: isDarkMode
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.error,
      // i am pretty much using this row to center the text
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Error!!',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    ),
  );
}

bool isPhoneNumberValid(String phoneNumber) {
  if (phoneNumber.length == 11) {
    return true;
  }
  return false;
}

Future<bool> checkIfNumberExists(String phoneNumber) async {
  final db = FirebaseFirestore.instance;
  final docRef = db.collection("users").doc(phoneNumber);
  final document = await docRef.get();

  return document.exists;
}

Color deJsonifyColor(Map<String, dynamic> colorMap) {
  return Color.fromARGB(
    colorMap['alpha']!,
    colorMap['red']!,
    colorMap['green']!,
    colorMap['blue']!,
  );
}

Map<String, int> jsonifyColor(Color color) {
  return {
    'red': color.red,
    'blue': color.blue,
    'green': color.green,
    'alpha': color.alpha,
  };
}

List<Recent> getRecentsForAContact(
    List<Recent> allRecents, String phoneNumber) {
  final recentsForThatContact = allRecents
      .where(
        (element) => element.contact.phoneNumber == phoneNumber,
      )
      .toList();
  return recentsForThatContact;
}

void showFlushBar(Color color, String message, FlushbarPosition position,
    BuildContext context) {
  Flushbar().dismiss();

  Flushbar(
    animationDuration: const Duration(milliseconds: 800),
    backgroundColor: color,
    margin: position == FlushbarPosition.TOP
        ? const EdgeInsets.only(top: 20, left: 10, right: 10)
        : const EdgeInsets.only(left: 10, right: 10, bottom: 20),
    messageText: Text(
      message,
      style: const TextStyle(fontSize: 16, color: Colors.white),
    ),
    duration: const Duration(seconds: 4),
    flushbarPosition: position,
    borderRadius: BorderRadius.circular(20),
    icon: const Icon(Icons.notifications),
    flushbarStyle: FlushbarStyle.FLOATING,
  ).show(context);
}

Color makeColorLighter(Color color, int amount) {
  final red = (color.red + amount).clamp(0, 255);
  final green = (color.green + amount).clamp(0, 255);
  final blue = (color.blue + amount).clamp(0, 255);

  return Color.fromARGB(255, red, green, blue);
}

enum AccessRequestStatus {
  granted,
  denied,
}

Future<void> sendAccessRequestStatus(
    AccessRequestStatus accessRequestStatus) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final recentId = prefs.getString('recentId');
  final requesterPhoneNumber = prefs.getString('requesterPhoneNumber');
  final requesteePhoneNumber = prefs.getString('phoneNumber');

  if (accessRequestStatus == AccessRequestStatus.granted) {
    final url = Uri.https('text-call-backend.onrender.com',
        'request_status/granted/$requesterPhoneNumber/$requesteePhoneNumber/$recentId');
    http.get(url);
    return;
  }
  final url = Uri.https('text-call-backend.onrender.com',
      'request_status/denied/$requesterPhoneNumber/$requesteePhoneNumber/$recentId');
  http.get(url);
}
