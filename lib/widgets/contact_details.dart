import 'package:flutter/material.dart';
import 'package:text_call/models/contact.dart';

class ContactDetails extends StatelessWidget {
  const ContactDetails({
    super.key,
    this.contact,
  });

  final Contact? contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              contact == null
                  ? 'Select a contact from the list on the left'
                  : contact!.name,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
