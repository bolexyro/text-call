import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessageWriter extends StatefulWidget {
  const MessageWriter({
    super.key,
    required this.calleePhoneNumber,
  });

  final String calleePhoneNumber;

  @override
  State<MessageWriter> createState() => _MessageWriterState();
}

class _MessageWriterState extends State<MessageWriter> {
  final TextEditingController _messageController = TextEditingController();

  // Future<void> _showNotification() async {
  void _callSomeone(context) async {
    final url = Uri.https('text-call-backend.onrender.com', 'call-user/');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    print('callee ${widget.calleePhoneNumber}');
    final response = await http.post(
      url,
      body: json.encode({
        'caller_phone_number': phoneNumber,
        'callee_phone_number': widget.calleePhoneNumber,
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
