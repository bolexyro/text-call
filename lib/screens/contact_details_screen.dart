import 'package:flutter/material.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_details_pane.dart';

class ContactDetailsScreen extends StatelessWidget {
  const ContactDetailsScreen({
    super.key,
    required this.selectedContact,
    required this.selectedRecent,
  });

  final Recent? selectedRecent;
  final Contact? selectedContact;

  @override
  Widget build(BuildContext context) {    
    const stackPadding = EdgeInsets.symmetric(horizontal: 10);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? null
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: selectedRecent == null
              ? ContactDetailsPane(
                  contact: selectedContact,
                  stackContainerWidths: MediaQuery.sizeOf(context).width -
                      stackPadding.horizontal,
                )
              : ContactDetailsPane(
                  recent: selectedRecent,
                  stackContainerWidths: MediaQuery.sizeOf(context).width -
                      stackPadding.horizontal,
                ),
        ),
      ),
    );
  }
}
