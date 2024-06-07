import 'package:flutter/material.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_details_pane.dart';

class ContactDetailsScreen extends StatelessWidget {
  const ContactDetailsScreen({
    super.key,
    required this.selectedContact,
  });

  final Contact? selectedContact;

  @override
  Widget build(BuildContext context) {
    const stackPadding = EdgeInsets.symmetric(horizontal: 10);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? null
          : Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? null
            : Colors.grey[200],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ContactDetailsPane(
            contact: selectedContact,
            stackContainerWidths:
                MediaQuery.sizeOf(context).width - stackPadding.horizontal,
          ),
        ),
      ),
    );
  }
}
