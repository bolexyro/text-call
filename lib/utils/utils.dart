import 'dart:io';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/widgets/contacts_screen_widgets/add_contact_dialog.dart';
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
          '10${currentDate.day}${currentDate.hour}${currentDate.minute}${currentDate.second}'),
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

// Future<bool> checkForInternetConnection(BuildContext context) async {
//   if(await InternetConnection().hasInternetAccess){
//     return true;
//   }
//    showADialog(
//         header: 'Error!!',
//         body: 'Connect to the internet and try again.',
//         context: context,
//         buttonText: 'ok',
//         onPressed: () => Navigator.of(context).pop());
//     return false;
// }

Future<void> showMessageWriterModalSheet(
    {required BuildContext context,
    required String calleeName,
    required String calleePhoneNumber}) async {
  // if (!await checkForInternetConnection(context)) {
  showModalBottomSheet(
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (ctx) => MessageWriter(
      calleePhoneNumber: calleePhoneNumber,
    ),
  );

  // }
}

Future<sql.Database> getDatabase() async {
  final databasesPath = await sql.getDatabasesPath();

  final db = await sql.openDatabase(
    path.join(databasesPath, 'contacts.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE contacts (phoneNumber TEXT PRIMARY KEY, name TEXT, imagePath TEXT)');
      await db.execute(
          'CREATE TABLE recents ( id TEXT , callTime TEXT PRIMARY KEY , phoneNumber TEXT, categoryName TEXT, message TEXT, backgroundColorRed INTEGER, backgroundColorGreen INTEGER, backgroundColorBlue INTEGER, backgroundColorAlpha INTEGER)');
    },
  );
  return db;
}

Future<Contact?> showAddContactDialog(context,
    {String? phoneNumber, Contact? contact}) async {
  // name and phonenumber would be returned when we are updating contact for it to reflect in the contact card stack
  final Contact? returnedContact = await showAdaptiveDialog(
    context: context,
    builder: (context) {
      return AddContactDialog(
        phoneNumber: phoneNumber,
        contact: contact,
      );
    },
  );
  return returnedContact;
}

void showADialog({
  required String header,
  required String body,
  required BuildContext context,
  required String buttonText,
  required void Function() onPressed,
}) async {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      backgroundColor: isDarkMode
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.error,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            header,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text(buttonText.toUpperCase()),
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

void sendAccessRequest(Recent recent) async {
  final prefs = await SharedPreferences.getInstance();
  final String? requesterPhoneNumber = prefs.getString('phoneNumber');
  final url = Uri.https('text-call-backend.onrender.com',
      'send-access-request/$requesterPhoneNumber/${recent.contact.phoneNumber}/${recent.id}');
  http.get(url);
}

Future<File?> selectImage(BuildContext context) async {
  ImageSource? source;
  FocusManager.instance.primaryFocus?.unfocus();
  await showModalBottomSheet(
    // backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 10,
        ),
        Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.grey,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  source = ImageSource.camera;
                  Navigator.of(context).pop();
                },
                iconSize: 40,
                icon: const Icon(
                  Icons.camera_alt_rounded,
                )),
            IconButton(
                iconSize: 40,
                onPressed: () {
                  source = ImageSource.gallery;
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.photo_library_rounded,
                )),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    ),
  );

  if (source == null) {
    return null;
  }
  final ImagePicker picker = ImagePicker();
  final XFile? pickedImage = await picker.pickImage(source: source!);
  if (pickedImage == null) {
    return null;
  }

  return File(pickedImage.path);
}
