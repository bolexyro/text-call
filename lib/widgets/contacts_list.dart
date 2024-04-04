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
    return Column(
      children: [
        const Text(
          'Phone',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        Text('${contacts.length} contacts with phone number'),
        const SizedBox(
          height: 70,
        ),
        Row(
          children: [
            const Spacer(),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            const SizedBox(width: 10),
            Badge(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              Contact contactN = contactsList[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                leading: CircleAvatar(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple,
                          Colors.blue,
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
          ),
        ),
      ],
    );
  }
}
