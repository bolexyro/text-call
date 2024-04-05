import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class MessageWriter extends StatelessWidget {
  const MessageWriter({super.key});

  Future<void> _showNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 123,
        channelKey: 'basic_channel',
        color: Colors.white,
        title: 'It is working bolexyro',
        body: 'it is working sir',
        category: NotificationCategory.Call,
        fullScreenIntent: true,
        autoDismissible: false,
        wakeUpScreen: true,
        backgroundColor: Colors.orange,
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'ACCEPT',
            label: 'Accept Call',
            color: Colors.green,
            autoDismissible: true),
        NotificationActionButton(
            key: 'REJECT',
            label: 'Reject Call',
            color: Colors.red,
            autoDismissible: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  minLines: 4,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Enter the message you want to call them with',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Message',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                IconButton(
                  onPressed: _showNotification,
                  icon: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.phone,
                      size: 35,
                    ),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
