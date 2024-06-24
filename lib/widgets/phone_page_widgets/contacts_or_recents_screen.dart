import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/screens/contact_details_screen.dart';
import 'package:text_call/widgets/sent_message_screen_widgets.dart';
import 'package:text_call/screens/sent_message_screens/sms_not_from_terminaed.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_details_pane.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contacts_list.dart';
import 'package:text_call/widgets/options_menu_anchor.dart';
import 'package:text_call/widgets/recents_screen_widgets/recents_list.dart';

enum WhichScreen { contact, recent }

class ContactsRecentsScreen extends ConsumerStatefulWidget {
  const ContactsRecentsScreen({
    super.key,
    required this.whichScreen,
    required this.scaffoldKey,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

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

  void _setCurrentRecent(Recent? selectedRecent) {
    setState(() {
      _currentRecent = selectedRecent;
    });
  }

  void _goToPage({required Contact selectedContact}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactDetailsScreen(
          selectedContact: selectedContact,
        ),
      ),
    );
  }

  void _resetContactDetailsPane(Contact deletedContact) {
    if (deletedContact.phoneNumber == _currentContact?.phoneNumber) {
      setState(() {
        _currentContact = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double availableWidth = MediaQuery.sizeOf(context).width;

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (widget.whichScreen == WhichScreen.contact) {
      if (availableWidth > kTabletWidth) {
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
            : Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      OptionsMenuAnchor(
                        contact: _currentContact!,
                        onContactDeleted: _resetContactDetailsPane,
                      ),
                    ],
                  ),
                  Expanded(
                    child: ContactDetailsPane(
                      key: ObjectKey(_currentContact),
                      contact: _currentContact,
                      stackContainerWidths:
                          MediaQuery.sizeOf(context).width * .425,
                    ),
                  ),
                ],
              );
        return Row(
          children: [
            Expanded(
              child: ContactsList(
                onContactDeleted: _resetContactDetailsPane,
                scaffoldKey: widget.scaffoldKey,
                screen: Screen.tablet,
                onContactSelected: _setCurrentContact,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? makeColorLighter(Theme.of(context).primaryColor, 15)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: activeContent,
              ),
            ),
          ],
        );
      }

      return ContactsList(
        onContactDeleted: _resetContactDetailsPane,
        scaffoldKey: widget.scaffoldKey,
        screen: Screen.phone,
        onContactSelected: (Contact selectedContact) =>
            _goToPage(selectedContact: selectedContact),
      );
    }

    if (availableWidth > kTabletWidth) {
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
          : ContactDetailsPane(
              key: ObjectKey(_currentRecent!),
              recent: _currentRecent,
              stackContainerWidths: MediaQuery.sizeOf(context).width * .425,
            );

      return Row(
        children: [
          Expanded(
            child: RecentsList(
              scaffoldKey: widget.scaffoldKey,
              screen: Screen.tablet,
              onRecentSelected: _setCurrentRecent,
            ),
          ),
          // Color.fromARGB(255, 11, 18, 25)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? makeColorLighter(Theme.of(context).primaryColor, 15)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: activeContent,
            ),
          ),
        ],
      );
    }
    return RecentsList(
      scaffoldKey: widget.scaffoldKey,
      onRecentSelected: (Recent? selectedRecent) {
        if (selectedRecent == null) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SmsNotFromTerminated(
              isRecentOutgoing: recentIsOutgoing(selectedRecent.category),
              recentCallTime: selectedRecent.callTime,
              howSmsIsOpened:
                  HowSmsIsOpened.notFromTerminatedToJustDisplayMessage,
              regularMessage: selectedRecent.regularMessage,
              complexMessage: selectedRecent.complexMessage,
            ),
          ),
        );
      },
      screen: Screen.phone,
    );
  }
}
