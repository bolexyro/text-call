import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/complex_message.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/models/regular_message.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/crud.dart';
import 'package:text_call/widgets/camera_or_gallery.dart';
import 'package:text_call/widgets/dialogs/add_contact_dialog.dart';
import 'package:text_call/widgets/message_writer.dart';
import 'package:http/http.dart' as http;

enum Screen { phone, tablet }

enum NotificationPurpose { forCall, forAccessRequest }

String changeLocalToIntl(String localPhoneNumber) =>
    '+234${localPhoneNumber.substring(1)}';

String changeIntlToLocal(String intlPhoneNumber) =>
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
    required String calleePhoneNumber,
    RegularMessage? regularMessage,
    ComplexMessage? complexMessage,
    bool? canBeViewed}) async {
  // if (!await checkForInternetConnection(context)) {
  showModalBottomSheet(
    useSafeArea: true,
    enableDrag: false,
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (ctx) => MessageWriter(
      calleePhoneNumber: calleePhoneNumber,
      regularMessageForRecall: regularMessage,
      complexMessageForRecall: complexMessage,
      canBeViewed: canBeViewed,
    ),
  );

  // }
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
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
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
          const SizedBox(
            height: 10,
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

bool checkIfContactIsAlreadyInContactList(
    String newContactPhoneNumber, WidgetRef ref) {
  final allContacts = ref.read(contactsProvider);
  for (final eachContact in allContacts) {
    if (newContactPhoneNumber == eachContact.phoneNumber) {
      return true;
    }
  }
  return false;
}

Future<bool> checkIfNumberExists(String phoneNumber) async {
  final db = FirebaseFirestore.instance;
  final docRef = db.collection("users").doc(phoneNumber);
  final document = await docRef.get();

  return document.exists;
}

Color deJsonifyColorMapToColor(Map<String, dynamic> colorMap) {
  return Color.fromARGB(
    colorMap['alpha']!,
    colorMap['red']!,
    colorMap['green']!,
    colorMap['blue']!,
  );
}

Map<String, dynamic> jsonifyColor(Color color) {
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

GlobalKey showFlushBar(Color color, String message, FlushbarPosition position,
    BuildContext context,
    {Widget? mainButton}) {
  final GlobalKey flushBarKey = GlobalKey();
  Flushbar(
    key: flushBarKey,
    mainButton: mainButton,
    animationDuration: const Duration(milliseconds: 800),
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    backgroundColor: color,
    margin: position == FlushbarPosition.TOP
        ? const EdgeInsets.only(top: 20, left: 10, right: 10)
        : const EdgeInsets.only(left: 10, right: 10, bottom: 20),
    messageText: Text(
      message,
      style: const TextStyle(fontSize: 16, color: Colors.white),
    ),
    duration: mainButton == null
        ? const Duration(seconds: 4)
        : const Duration(seconds: 100),
    flushbarPosition: position,
    borderRadius: BorderRadius.circular(20),
    icon: const Icon(Icons.notifications),
    flushbarStyle: FlushbarStyle.FLOATING,
  ).show(context);
  return flushBarKey;
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
    {required AccessRequestStatus accessRequestStatus,
    required Map<String, dynamic> payload}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final requesteePhoneNumber = prefs.getString('myPhoneNumber');

  if (accessRequestStatus == AccessRequestStatus.granted) {
    final url = Uri.https(backendRootUrl,
        'request_status/granted/${payload['requesterPhoneNumber']}/$requesteePhoneNumber/${payload['recentId']}');
    http.get(url);
    return;
  }
  final url = Uri.https(backendRootUrl,
      'request_status/denied/${payload['requesterPhoneNumber']}/$requesteePhoneNumber/${payload['recentId']}');
  http.get(url);
}

void sendAccessRequest(Recent recent, WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final String? requesterPhoneNumber = prefs.getString('myPhoneNumber');
  insertAccessRequestIntoDb(recentId: recent.id, isSent: true);
  ref.read(recentsProvider.notifier).updateRecentAccessRequestPendingStatus(
      recentId: recent.id, isPending: true);
  final url = Uri.https(backendRootUrl,
      'send-access-request/$requesterPhoneNumber/${recent.contact.phoneNumber}/${recent.id}');
  http.get(url);
}

Future<File?> selectImage(BuildContext context) async {
  FocusManager.instance.primaryFocus?.unfocus();
  ImageSource? source = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => const CameraOrGallery());

  if (source == null) {
    return null;
  }
  final ImagePicker picker = ImagePicker();
  final XFile? pickedImage = await picker.pickImage(source: source);
  if (pickedImage == null) {
    return null;
  }

  return File(pickedImage.path);
}

Future<void> setPreferencesUpdateLocalAndRemoteDb({
  required String phoneNumber,
  required WidgetRef ref,
  required BuildContext context,
  required bool updateMeContact,
  String? phoneNumberToBeUpdated,
}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isUserLoggedIn', true);
  await prefs.setString('myPhoneNumber', phoneNumber);

  final db = FirebaseFirestore.instance;
  final fcm = FirebaseMessaging.instance;

  if (updateMeContact) {
    await ref.read(contactsProvider.notifier).loadContacts();
    final originalContact = ref
        .read(contactsProvider)
        .where((contact) => contact.phoneNumber == phoneNumberToBeUpdated)
        .first;

    // if the new number is already a contact, update the name to me
    // and the previos me should be me(previous)
    final contactAlreadyExistingWithNewPhoneNumber = ref
        .read(contactsProvider)
        .where((contact) => contact.phoneNumber == phoneNumber)
        .toList();

    if (contactAlreadyExistingWithNewPhoneNumber.isNotEmpty) {
      ref.read(contactsProvider.notifier).updateContact(
            ref: ref,
            oldContactPhoneNumber: phoneNumber,
            newContact: Contact(
              name: originalContact.name,
              phoneNumber: phoneNumber,
              imagePath: originalContact.imagePath,
            ),
          );
      ref.read(contactsProvider.notifier).updateContact(
            ref: ref,
            oldContactPhoneNumber: originalContact.phoneNumber,
            newContact: Contact(
              name: '${originalContact.name}(previous)',
              phoneNumber: originalContact.phoneNumber,
              imagePath: originalContact.imagePath,
            ),
          );
    } else {
      ref.read(contactsProvider.notifier).updateContact(
            ref: ref,
            oldContactPhoneNumber: originalContact.phoneNumber,
            newContact: Contact(
              name: originalContact.name,
              phoneNumber: phoneNumber,
              imagePath: originalContact.imagePath,
            ),
          );
    }
    db.collection("users").doc(originalContact.phoneNumber).delete();
  } else {
    ref.read(contactsProvider.notifier).addContact(
          ref,
          Contact(
            name: "Me",
            phoneNumber: phoneNumber,
            imagePath: null,
          ),
        );
  }

  final fcmToken = await fcm.getToken();
  // Add a new document with a specified ID
  db.collection("users").doc(phoneNumber).set(
    {'fcmToken': fcmToken},
  );
  await ref.read(contactsProvider.notifier).loadContacts();

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => PhonePageScreen(myPhoneNumber: phoneNumber),
    ),
  );
}

Future<String> messagesDirectoryPath({
  required bool isTemporary,
  required String? specificDirectory,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  String path =
      '${directory.path}/messages/${isTemporary ? 'temporary' : 'permanent'}';
  if (specificDirectory != null) {
    path =
        '${directory.path}/messages/${isTemporary ? 'temporary' : 'permanent'}/$specificDirectory';
  }

  final dir = Directory(path);
  if (!(await dir.exists())) {
    await dir.create(recursive: true);
  }

  return path;
}

Future<void> deleteFile(String filePath) async {
  final file = File(filePath);
  print('file exsts ${await file.exists()}');
  try {
    if (await file.exists()) {
      await file.delete();
      print('file deleted');
    }
  } catch (e) {
    print('Error bro $e');
  }
}

Future<void> deleteDirectory(String dirPath) async {
  final directory = Directory(dirPath);

  try {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      print('folder deleted');
    }
  } catch (e) {
    print('Error bro $e');
  }
}

// since the user cannot really choose which medias in a message to keep available offline and so when they
// save a message offline, the audio, video, image would be made available offline.
// so we can say if the localPath of maybe the audio is not null, then the message is available offline.
bool isMessageAvailableOffline(Map<String, dynamic> bolexyroJson) {
  for (final indexMainMediaMapPair in bolexyroJson.entries) {
    // Skip 'document' entries
    if (indexMainMediaMapPair.value.keys.first != 'document') {
      // Get the media map (audio, video, image)
      final mediaMap = indexMainMediaMapPair.value.values.first;

      // Iterate through media map entries
      for (final mediaEntry in mediaMap.entries) {
        // Check if the 'local' path is not null
        if (mediaEntry.value['local'] != null) {
          return true;
        }
      }
    }
  }

  return false;
}

Future<String?> storeFileInPermanentDirectory({
  required File sourceFile,
  required String fileName,
  required String fileType,
  required String imageDirectoryPath,
  required String audioDirectoryPath,
  required String videoDirectoryPath,
}) async {
  late String destinationPath;
  if (fileType == 'image') {
    destinationPath = '$imageDirectoryPath/$fileName';
  } else if (fileType == 'video') {
    destinationPath = '$videoDirectoryPath/$fileName';
  } else {
    destinationPath = '$audioDirectoryPath/$fileName';
  }

  if (await sourceFile.exists()) {
    print(destinationPath);
    await sourceFile.copy(destinationPath);
    print('File copied.');
    return destinationPath;
  } else {
    print('Source file does not exist.');
    return null;
  }
}

Future<File> downloadFileFromUrl(String url, String tempPath) async {
  final mediaRef = FirebaseStorage.instance.refFromURL(url);
  final file = File(tempPath);
  final downloadTask = mediaRef.writeToFile(file);

  downloadTask.snapshotEvents.listen((taskSnapshot) {
    switch (taskSnapshot.state) {
      case TaskState.running:
        break;
      case TaskState.paused:
        break;
      case TaskState.success:
        break;
      case TaskState.canceled:
        break;
      case TaskState.error:
        break;
    }
  });

  await downloadTask;
  return file;
}

bool bolexyroJsonContainsOnlyRichText(
    Map<String, dynamic> bolexyroJsonToCheck) {
  final bolexyroJson = jsonDecode(jsonEncode(bolexyroJsonToCheck));
  for (final entry in bolexyroJson.entries) {
    final mediaType = entry.value.keys.first;
    if (mediaType != 'document') {
      return false;
    }
  }
  return true;
}

String groupHeaderText(DateTime headerDateTime) {
  if (DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day) ==
      DateTime(headerDateTime.year, headerDateTime.month, headerDateTime.day)) {
    return "Today";
  } else if (DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day - 1) ==
      DateTime(headerDateTime.year, headerDateTime.month, headerDateTime.day)) {
    return 'Yesterday';
  }
  return DateFormat('EEEE, d MMMM').format(headerDateTime);
}

String formatDuration(Duration duration) {
  int totalSeconds = duration.inSeconds;
  int seconds = totalSeconds % 60;
  int totalMinutes = totalSeconds ~/ 60;
  int minutes = totalMinutes % 60;
  int hours = totalMinutes ~/ 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else if (minutes > 0) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else {
    return '0:${seconds.toString().padLeft(2, '0')}';
  }
}

bool recentIsOutgoing(RecentCategory recentCategory) {
  if ([
    RecentCategory.incomingAccepted,
    RecentCategory.incomingIgnored,
    RecentCategory.incomingRejected
  ].contains(recentCategory)) {
    return false;
  }
  return true;
}
