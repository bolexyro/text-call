import 'package:flutter/material.dart';

class MessageWriter extends StatelessWidget {
  const MessageWriter({super.key});

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
                  onPressed: () {},
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
