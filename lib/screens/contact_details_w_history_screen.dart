import 'package:flutter/material.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_details.dart';

class ContactDetailsWHistoryScreen extends StatelessWidget {
  const ContactDetailsWHistoryScreen({
    super.key,
    required this.contact,
  });

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    const stackPadding = EdgeInsets.symmetric(horizontal: 10);

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              Expanded(
                child: ContactDetails(
                  contact: contact,
                  stackContainerWidths: MediaQuery.sizeOf(context).width -
                      stackPadding.horizontal,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
