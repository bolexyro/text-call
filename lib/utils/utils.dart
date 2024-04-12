import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:text_call/widgets/message_writer.dart';

void createAwesomeNotification({String? title, String? body}) {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 123,
      channelKey: 'basic_channel',
      color: Colors.white,
      title: title,
      body: body,
      category: NotificationCategory.Call,
      fullScreenIntent: true,
      autoDismissible: false,
      wakeUpScreen: true,
      backgroundColor: Colors.orange,
      locked: true,
      chronometer: Duration.zero, // Chronometer starts to count at 0 seconds
      timeoutAfter: const Duration(seconds: 20),
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'ACCEPT',
        label: 'Accept Call',
        color: Colors.green,
        autoDismissible: true,
      ),
      NotificationActionButton(
        key: 'REJECT',
        label: 'Reject Call',
        color: Colors.red,
        autoDismissible: true,
        actionType: ActionType.SilentBackgroundAction,
      ),
    ],
  );
}

String formatPhoneNumber({required String phoneNumberWCountryCode}) {
  return '0${phoneNumberWCountryCode.substring(4)}';
}

void showMessageWriterModalSheet(
    {required BuildContext context, required String phoneNumber}) {
  showModalBottomSheet(
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (ctx) => MessageWriter(
      calleePhoneNumber: phoneNumber,
    ),
  );
}
