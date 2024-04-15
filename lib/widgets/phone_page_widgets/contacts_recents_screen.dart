import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/screens/recent_details_screen.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_details.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contacts_list.dart';
import 'package:text_call/widgets/recents_screen_widgets/recents_list.dart';

enum Purpose { forContacts, forRecents }

class ContactsRecentsScreen extends ConsumerStatefulWidget {
  const ContactsRecentsScreen({
    super.key,
    required this.purpose,
  });

  final Purpose purpose;
  @override
  ConsumerState<ContactsRecentsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsRecentsScreen> {
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

  void _goToContactPage(Contact selectedContact) {
    // so I am using the
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecentDetailsScreen(
          recent: Recent(
            contact: selectedContact,
            category: RecentCategory.incomingRejected,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double availableWidth = MediaQuery.sizeOf(context).width;

    if (widget.purpose == Purpose.forContacts) {
      if (availableWidth > 500) {
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

      return Scaffold(
        body: ContactsList(onContactSelected: _goToContactPage),
      );
    }

    return const Scaffold(
      body: RecentsList(),
    );
  }
}
