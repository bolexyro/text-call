import 'package:flutter/material.dart';
import 'package:text_call/data/contacts.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/widgets/contact_details.dart';
import 'package:text_call/widgets/contacts_list.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  Contact? _currentContact;

  void _setCurrentContact(Contact selectedContact) {
    setState(() {
      _currentContact = selectedContact;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ContactsList(
            contactsList: contacts,
            onContactSelected: _setCurrentContact,
          ),
        ),
        Expanded(
          child: ContactDetails(contact: _currentContact),
        ),
      ],
    );
  }
}
