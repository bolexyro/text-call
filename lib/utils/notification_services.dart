import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/complex_message.dart';
import 'package:text_call/models/regular_message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/widgets/sent_message_screen_widgets.dart';
import 'package:text_call/screens/sent_message_screens/sms_not_from_terminaed.dart';
import 'package:text_call/text_call.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/crud.dart';
import 'package:text_call/utils/db_schema.dart';
import 'package:text_call/utils/utils.dart';

Future<String> _getCallerName(String phoneNumber) async {
  final data = await readContactsFromDb(wherePhoneNumber: phoneNumber);
  if (data.isEmpty) {
    return changeIntlToLocal(phoneNumber);
  } else {
    return data[0]['name'] as String;
  }
}

Future<void> messageHandler(RemoteMessage message) async {
  // wsince this message handler is registered by bothe the foreground and background fcm listeners, we would have 2 listeners
  // for the call kit. so for the http requests,
  registerCallkitIncomingListener();

  final String notificationPurpose = message.data['purpose'];

  if (notificationPurpose == 'access_request') {
    final String recentId = message.data['message_id'];
    final String requesterPhoneNumber = message.data['requester_phone_number'];

    final String requesterName = await _getCallerName(requesterPhoneNumber);

    final currentDate = DateTime.now();

    await insertAccessRequestIntoDb(recentId: recentId, isSent: false);
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          // the id is used to identify each notification. So if you have a static id like 123, when a new notification comes in, the old one goes out.
          id: int.parse(
              '10${currentDate.day}${currentDate.hour}${currentDate.minute}${currentDate.second}'),
          channelKey: 'access_requests_channel',
          color: Colors.black,
          title: '$requesterName is Requesting access to see a message',
          body: 'Click on this notification to see this message',
          autoDismissible: true,
          category: NotificationCategory.Call,
          fullScreenIntent: true,
          wakeUpScreen: true,
          backgroundColor: Colors.green,
          locked: false,
          chronometer: null, // Chronometer starts to count at 0 seconds
          timeoutAfter: null,
          payload: {
            'recentId': recentId,
            'requesterPhoneNumber': requesterPhoneNumber,
          }),
      actionButtons: [
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

    return;
  }

  if (notificationPurpose == 'request_status') {
    final String recentId = message.data['message_id'];
    final String accessRequestStatus = message.data['access_request_status'];
    final String requesteePhoneNumber = message.data['requestee_phone_number'];
    final String requesteeName = await _getCallerName(requesteePhoneNumber);

    if (accessRequestStatus == 'granted') {
      final DateTime currentDate = DateTime.now();
      final db = await getDatabase();

      await db.update(
        'recents',
        {
          'canBeViewed': 1,
          'accessRequestPending': 0,
        },
        where: 'id = ?',
        whereArgs: [recentId],
      );
      // this one is to update the access requests that's already in the db.
      // So, if it were pending before, it would change to either accepted or declined.
      insertAccessRequestIntoDb(recentId: recentId, isSent: true);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: int.parse(
              '12${currentDate.day}${currentDate.hour}${currentDate.minute}${currentDate.second}'),
          channelKey: 'access_requests_channel',
          color: Colors.black,
          title: 'Access Request Update',
          body: '$requesteeName has granted your request. Tap to see message',
          autoDismissible: true,
          category: NotificationCategory.Call,
          fullScreenIntent: true,
          wakeUpScreen: true,
          backgroundColor: Colors.green,
          locked: false,
          payload: {'recentId': recentId},
        ),
      );
    }
    if (accessRequestStatus == 'denied') {
      final db = await getDatabase();

      await db.update(
        'recents',
        {
          'accessRequestPending': 0,
        },
        where: 'id = ?',
        whereArgs: [recentId],
      );
      final DateTime currentDate = DateTime.now();

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: int.parse(
              '11${currentDate.day}${currentDate.hour}${currentDate.minute}${currentDate.second}'),
          channelKey: 'access_requests_channel',
          color: Colors.black,
          title: 'Access Request Update',
          body: '$requesteeName has denied your request',
          autoDismissible: true,
          category: NotificationCategory.Status,
          fullScreenIntent: true,
          wakeUpScreen: true,
          backgroundColor: Colors.green,
          locked: false,
          payload: {'recentId': recentId},
        ),
      );
    }
    return;
  }

  final String recentId = message.data['message_id'];
  final String messageJsonString = message.data['message_json_string'];
  final String callerPhoneNumber = message.data['caller_phone_number'];
  final String messageType = message.data['my_message_type'];
  final String callerName = await _getCallerName(callerPhoneNumber);

  final prefs = await SharedPreferences.getInstance();
  final List<String> blockedContacts =
      prefs.getStringList('blockedPhoneNumbers') ?? [];
  String? blockMessage;
  if (blockedContacts.map((eachJsonString) {
    final eachJsonMap = jsonDecode(eachJsonString);
    if (eachJsonMap['phoneNumber'] == callerPhoneNumber) {
      blockMessage = eachJsonMap['blockMessage'];
    }
    return eachJsonMap['phoneNumber'];
  }).contains(callerPhoneNumber)) {
    final url = Uri.https(
        backendRootUrl, 'call/blocked/$callerPhoneNumber/$blockMessage');
    await http.get(
      url,
      headers: {
        'x-api-key': dotenv.env['TEXTCALL_BACKEND_API_KEY']!,
      },
    );
    return;
  }

  // NB to future self. This is not useless code, it is useful for when user is called in terminated state, since they won't have
  // access to the event body. Sha don't delete it
  await prefs.setString('recentId', recentId);
  await prefs.setString('messageJsonString', messageJsonString);
  await prefs.setString('callerPhoneNumber', callerPhoneNumber);
  await prefs.setString('messageType', messageType);

  CallKitParams callKitParams = CallKitParams(
    id: recentId,
    nameCaller: callerName,
    appName: 'TextCall',
    handle: callerPhoneNumber,
    type: 0,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const NotificationParams(
      showNotification: true,
      isShowCallback: false,
      subtitle: 'Missed Text Call',
      // callbackText: 'Call back',
    ),
    duration: 20000,
    extra: <String, dynamic>{
      'recentId': recentId,
      'messageJsonString': messageJsonString,
      'messageType': messageType,
    },
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#36618e',
      // backgroundUrl: 'https://i.pravatar.cc/500',
      actionColor: '#4CAF50',
      textColor: '#ffffff',
      incomingCallNotificationChannelName: "Incoming Call",
      missedCallNotificationChannelName: "Missed Call",
      isShowCallID: false,
    ),
    ios: const IOSParams(
      iconName: 'CallKitLogo',
      handleType: 'generic',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
  );
  if (notificationPurpose == 'end_call') {
    // if you do this, it would register an incoming rejected call in the db, and we don't want that. So I will manually try and show missedd call notification
    // await FlutterCallkitIncoming.endAllCalls();
    await FlutterCallkitIncoming.showMissCallNotification(callKitParams);
    await FlutterCallkitIncoming.hideCallkitIncoming(callKitParams);
    final newRecent = Recent.withoutContactObject(
      category: RecentCategory.incomingIgnored,
      canBeViewed: false,
      regularMessage: messageType == 'regular'
          ? RegularMessage.fromJsonString(messageJsonString)
          : null,
      complexMessage: messageType == 'complex'
          ? ComplexMessage(complexMessageJsonString: messageJsonString)
          : null,
      id: recentId,
      phoneNumber: callerPhoneNumber,
    );
    insertRecentIntoDb(newRecent: newRecent);
    return;
  }
  await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
}

Future<void> fcmSetup() async {
  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission();
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {
      await messageHandler(message);
    },
  );
}

// From what I understand, the onBackgroudMessage handler is in a different isolate and thus has no access to the data from the main isolate.
// So using gloabl variables and changing them with this background handler will not work
// https://stackoverflow.com/questions/65664203/flutter-global-variable-becomes-null-when-app-is-in-background
// https://github.com/firebase/flutterfire/issues/1878
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  await messageHandler(message);
}

void registerCallkitIncomingListener() {
  FlutterCallkitIncoming.onEvent.listen(
    (CallEvent? event) async {
      switch (event!.event) {
        case Event.actionCallIncoming:
          break;
        case Event.actionCallStart:
          break;
        case Event.actionCallAccept:
          final Map<String, dynamic> eventBody = event.body;
          final Map myDataInEventBody = eventBody['extra'];
          final String callerPhoneNumber = eventBody['number'];
          final String messageJsonString =
              myDataInEventBody['messageJsonString'];
          final String messageType = myDataInEventBody['messageType'];
          // final String recentId = myDataInEventBody['recentId'];

          final url =
              Uri.https(backendRootUrl, 'call/accepted/$callerPhoneNumber');
          http.get(
            url,
            headers: {
              'x-api-key': dotenv.env['TEXTCALL_BACKEND_API_KEY']!,
            },
          );

          final prefs = await SharedPreferences.getInstance();
          final bool? isUserLoggedIn = prefs.getBool('isUserLoggedIn');

          if (TextCall.navigatorKey.currentState != null) {
            if (isUserLoggedIn != true) {
              showFlushBar(Colors.blue, 'You have to login to see the message.',
                  FlushbarPosition.TOP, TextCall.navigatorKey.currentContext!);
              return;
            }

            Navigator.of(TextCall.navigatorKey.currentContext!).push(
              MaterialPageRoute(
                builder: (context) => SmsNotFromTerminated(
                  isRecentOutgoing: false,
                  recentCallTime: null,
                  complexMessage: messageType == 'complex'
                      ? ComplexMessage(
                          complexMessageJsonString: messageJsonString)
                      : null,
                  regularMessage: messageType == 'regular'
                      ? RegularMessage.fromJsonString(messageJsonString)
                      : null,
                  howSmsIsOpened: HowSmsIsOpened.notFromTerminatedForPickedCall,
                ),
              ),
            );
          } else {}

          break;
        case Event.actionCallDecline:
          final Map<String, dynamic> eventBody = event.body;
          final Map myDataInEventBody = eventBody['extra'];
          final String callerPhoneNumber = eventBody['number'];
          final String messageJsonString =
              myDataInEventBody['messageJsonString'];
          final String messageType = myDataInEventBody['messageType'];
          final String recentId = myDataInEventBody['recentId'];

          final url =
              Uri.https(backendRootUrl, 'call/rejected/$callerPhoneNumber');
          http.get(
            url,
            headers: {
              'x-api-key': dotenv.env['TEXTCALL_BACKEND_API_KEY']!,
            },
          );

          final newRecent = Recent.withoutContactObject(
            category: RecentCategory.incomingRejected,
            canBeViewed: false,
            regularMessage: messageType == 'regular'
                ? RegularMessage.fromJsonString(messageJsonString)
                : null,
            complexMessage: messageType == 'complex'
                ? ComplexMessage(complexMessageJsonString: messageJsonString)
                : null,
            id: recentId,
            phoneNumber: callerPhoneNumber,
          );
          insertRecentIntoDb(newRecent: newRecent);
          break;
        case Event.actionCallEnded:
          break;
        case Event.actionCallTimeout:
          final Map<String, dynamic> eventBody = event.body;
          final Map myDataInEventBody = eventBody['extra'];
          final String callerPhoneNumber = eventBody['number'];
          final String messageJsonString =
              myDataInEventBody['messageJsonString'];
          final String messageType = myDataInEventBody['messageType'];
          final String recentId = myDataInEventBody['recentId'];

          final url =
              Uri.https(backendRootUrl, 'call/ignored/$callerPhoneNumber');
          http.get(
            url,
            headers: {
              'x-api-key': dotenv.env['TEXTCALL_BACKEND_API_KEY']!,
            },
          );

          final newRecent = Recent.withoutContactObject(
            category: RecentCategory.incomingIgnored,
            canBeViewed: false,
            regularMessage: messageType == 'regular'
                ? RegularMessage.fromJsonString(messageJsonString)
                : null,
            complexMessage: messageType == 'complex'
                ? ComplexMessage(complexMessageJsonString: messageJsonString)
                : null,
            id: recentId,
            phoneNumber: callerPhoneNumber,
          );

          insertRecentIntoDb(newRecent: newRecent);
          break;
        case Event.actionCallCallback:
          break;
        case Event.actionCallToggleHold:
          break;
        case Event.actionCallToggleMute:
          break;
        case Event.actionCallToggleDmtf:
          break;
        case Event.actionCallToggleGroup:
          break;
        case Event.actionCallToggleAudioSession:
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          break;
        case Event.actionCallCustom:
          break;
      }
    },
  );
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
      ReceivedAction receivedAction) async {
    if (receivedAction.channelKey == 'calls_channel') {
      return;
    }
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'GRANT_ACCESS') {
      sendAccessRequestStatus(
          accessRequestStatus: AccessRequestStatus.granted,
          payload: receivedAction.payload!);
    } else if (receivedAction.buttonKeyPressed == 'DENY_ACCESS') {
      sendAccessRequestStatus(
          accessRequestStatus: AccessRequestStatus.denied,
          payload: receivedAction.payload!);
    }

    // for when the notification is tapped and not any buttons
    // notification ids beginning with 11, when we tap on them, nothing should happen. It would just open the app sha. This should be used for when notificatino shown is to tell you access request denied
    // notification ids beginning with 10, when we tap on them, we should be shown a message screen. this one shoudld be used when we are sending do you want to grant or deny access request.
    // notification ids beginning with 12, when we tap on them, we should be shown a message screen. but this one should be used when an access request has been granted.
    // so that you don't end up seeing the grant and deny buttons on the message screen.
    else {
      if (receivedAction.channelKey == 'access_requests_channel') {
        if (receivedAction.id!.toString().startsWith('11')) {
          return;
        }
        final notificationPayload = receivedAction.payload!;
        final String? recentId = notificationPayload['recentId'];

        final data = await readRecentsFromDb(whereId: recentId);

        if (data.isEmpty) {
          return;
        }

        Navigator.of(TextCall.navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (context) => SmsNotFromTerminated(
              isRecentOutgoing: false,
              notificationPayload: receivedAction.payload!,
              recentCallTime: DateTime.parse(data[0]['id'] as String),
              howSmsIsOpened: receivedAction.id!.toString().startsWith('10')
                  ? HowSmsIsOpened.notFromTerminatedToGrantOrDeyRequestAccess
                  : HowSmsIsOpened.notFromTerminatedToJustDisplayMessage,
              regularMessage: data[0]['messageType'] == 'regular'
                  ? RegularMessage.fromJsonString(
                      data[0]['messageJson'] as String,
                    )
                  : null,
              complexMessage: data[0]['messageType'] == 'complex'
                  ? ComplexMessage(
                      complexMessageJsonString:
                          data[0]['messageJson'] as String,
                    )
                  : null,
            ),
          ),
        );
      } else if (receivedAction.channelKey == 'calls_channel') {}
    }
  }
}
