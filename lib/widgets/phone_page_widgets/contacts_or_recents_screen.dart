import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/screens/contact_details_w_history_screen.dart';
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
  Contact? _currentRecent;

  @override
  void initState() {
    super.initState();
  }

  void _setCurrentContact(Contact selectedContact) {
    setState(() {
      _currentContact = selectedContact;
    });
  }

  void _setCurrentRecent(Contact selectedRecent) {
    setState(() {
      _currentRecent = selectedRecent;
    });
  }

  void _goToContactPage(Contact selectedContact) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ContactDetailsWHistoryScreen(contact: selectedContact),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double availableWidth = MediaQuery.sizeOf(context).width;

    double tabletWidth = 500;

    if (widget.purpose == Purpose.forContacts) {
      if (availableWidth > tabletWidth) {
        final activeContent = _currentContact == null
            ? const Padding(
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    'Select a contact from the list on the left',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              )
            : ContactDetails(
                contact: _currentContact!,
                stackContainerWidths: MediaQuery.sizeOf(context).width * .425,
              );

        return Row(
          children: [
            Expanded(
              child: ContactsList(
                onContactSelected: _setCurrentContact,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: activeContent,
              ),
            ),
          ],
        );
      }

      return ContactsList(onContactSelected: _goToContactPage);
    }

    if (availableWidth > tabletWidth) {
      final activeContent = _currentRecent == null
          ? const Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  'Select a call from the list on the left',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            )
          : ContactDetails(
              contact: _currentRecent!,
              stackContainerWidths: MediaQuery.sizeOf(context).width * .425,
            );

      return Row(
        children: [
          Expanded(
            child: RecentsList(
              onRecentSelected: _setCurrentRecent,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: activeContent,
            ),
          ),
        ],
      );
    }
    return RecentsList(onRecentSelected: _goToContactPage);
  }
}
