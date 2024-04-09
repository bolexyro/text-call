import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_details.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contacts_list.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  Contact? _currentContact;

  @override
  void initState() {
    super.initState();
  }

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
