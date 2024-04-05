import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:text_call/data/contacts.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/widgets/add_contact.dart';
import 'package:text_call/widgets/message_writer.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({
    super.key,
    required this.contactsList,
    required this.onContactSelected,
  });

  final List contactsList;
  final void Function(Contact selectedContact) onContactSelected;

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  void _showModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) =>  const MessageWriter(),
    );
  }

  void _showAddContactBottomSheet(context) async {
    final Contact? newContact = await showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AddContact();
      },
    );

    if (newContact != null) {
      setState(() {
        contacts.add(newContact);
      });
    }
  }

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
              onPressed: () {
                _showAddContactBottomSheet(context);
              },
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
              Contact contactN = widget.contactsList[index];
              return Slidable(
                startActionPane: ActionPane(
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        _showModalBottomSheet(context);
                      },
                      backgroundColor: const Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.message,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (context) {},
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.close,
                      label: 'Share',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {},
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                  title: Text(contactN.name),
                  onTap: () {
                    widget.onContactSelected(contactN);
                  },
                ),
              );
            },
            itemCount: contacts.length,
          ),
        ),
      ],
    );
  }
}
