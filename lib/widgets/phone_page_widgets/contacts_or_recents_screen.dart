import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_details.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contacts_list.dart';
import 'package:text_call/widgets/recents_screen_widgets/recents_list.dart';

enum WhichScreen { contact, recent }

class ContactsRecentsScreen extends ConsumerStatefulWidget {
  const ContactsRecentsScreen({
    super.key,
    required this.whichScreen,
  });

  final WhichScreen whichScreen;
  @override
  ConsumerState<ContactsRecentsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsRecentsScreen> {
  Contact? _currentContact;
  Recent? _currentRecent;

  @override
  void initState() {
    super.initState();
  }

  void _setCurrentContact(Contact selectedContact) {
    setState(() {
      _currentContact = selectedContact;
    });
  }

  void _setCurrentRecent(Recent selectedRecent) {
    setState(() {
      _currentRecent = selectedRecent;
    });
  }

  void _goToPage({Contact? selectedContact, Recent? selectedRecent}) {
    const stackPadding = EdgeInsets.symmetric(horizontal: 10);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SafeArea(
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
                    child: selectedRecent == null
                        ? ContactDetails(
                            contact: selectedContact,
                            stackContainerWidths:
                                MediaQuery.sizeOf(context).width -
                                    stackPadding.horizontal,
                          )
                        : ContactDetails(
                            recent: selectedRecent,
                            stackContainerWidths:
                                MediaQuery.sizeOf(context).width -
                                    stackPadding.horizontal,
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double availableWidth = MediaQuery.sizeOf(context).width;

    double tabletWidth = 520;

    if (widget.whichScreen == WhichScreen.contact) {
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

      return ContactsList(
        onContactSelected: (Contact selectedContact) =>
            _goToPage(selectedContact: selectedContact),
      );
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
              recent: _currentRecent,
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
    return RecentsList(onRecentSelected: (Recent selectedRecent) {
      _goToPage(selectedRecent: selectedRecent);
    });
  }
}
