import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/widgets/contact_details.dart';
import 'package:text_call/widgets/contacts_list.dart';


class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  Contact? _currentContact;
  late Future<void> _contactsListFuture;

  @override
  void initState() {
    _contactsListFuture = ref.read(contactsProvider.notifier).loadContacts();
    super.initState();
  }

  void _setCurrentContact(Contact selectedContact) {
    setState(() {
      _currentContact = selectedContact;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _contactsListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("An error occured please restart the app."),
          );
        }

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
      },
    );
  }
}
