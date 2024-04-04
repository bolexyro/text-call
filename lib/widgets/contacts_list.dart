import 'package:flutter/material.dart';
import 'package:text_call/data/contacts.dart';
import 'package:text_call/models/contact.dart';

class ContactsList extends StatelessWidget {
  const ContactsList({
    super.key,
    required this.contactsList,
    required this.onContactSelected,
  });

  final List contactsList;
  final void Function(Contact selectedContact) onContactSelected;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        Contact contactN = contactsList[index];
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          leading: CircleAvatar(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red,
                    Colors.yellow,
                  ],
                ),
              ),
              child: Text(
                contactN.name[0],
                style: const TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
          ),
          title: Text(contactN.name),
          onTap: () {
            onContactSelected(contactN);
          },
        );
      },
      itemCount: contacts.length,
    );
  }
}
