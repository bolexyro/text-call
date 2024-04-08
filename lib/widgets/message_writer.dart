import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessageWriter extends StatelessWidget {
  MessageWriter({
    super.key,
    required this.calleePhoneNumber,
  });

  final String calleePhoneNumber;
  final TextEditingController _messageController = TextEditingController();

  // Future<void> _showNotification() async {
  //   bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  //   if (!isAllowed) {
  //     // This is just a basic example. For real apps, you must show some
  //     // friendly dialog box before call the request method.
  //     // This is very important to not harm the user experience
  //     await AwesomeNotifications().requestPermissionToSendNotifications();
  //   }

  //     createAwesomeNotification(title: 'Bolexyro is calling', body: 'Very Important Message');
  // }

  void _callSomeone(context) async {
    final url =
        Uri.https('text-call-backend.onrender.com', 'call-user/');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    final response = await http.post(
      url,
      body: json.encode({
        'caller_phone_number': phoneNumber,
        'callee_phone_number': calleePhoneNumber,
        'message': _messageController.text,
      }),
      headers: {
      'Content-Type': 'application/json',
    },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Call sent successfully"),
        ),
      );
    }
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
                  // autofocus: true,
                  controller: _messageController,
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
                  onPressed: () => _callSomeone(context),
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
