import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/widgets/contacts_screen_widgets/add_contact.dart';
import 'package:text_call/widgets/message_writer.dart';

class ContactsList extends ConsumerStatefulWidget {
  const ContactsList({
    super.key,
    required this.onContactSelected,
  });

  final void Function(Contact selectedContact) onContactSelected;

  @override
  ConsumerState<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends ConsumerState<ContactsList> {
  void _showModalBottomSheet(context, String calleePhoneNumber) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (ctx) => MessageWriter(
        calleePhoneNumber: calleePhoneNumber,
      ),
    );
  }

  void _showAddContactDialog(context) async {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AddContact();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Contact> contactsList = ref.watch(contactsProvider);
    // List<Contact> contactsListFormatted = contactsList.map((contact) => Contact(name: contact.name, phoneNumber: '0${contact.phoneNumber.substring(4)}'),).toList();

    return Column(
      children: [
        const Text(
          'Phone',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text('${contactsList.length} contacts with phone number', textAlign: TextAlign.center,),
        ),
        const SizedBox(
          height: 70,
        ),
        Row(
          children: [
            const Spacer(),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                _showAddContactDialog(context);
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
        if (contactsList.isEmpty)
          const Center(
            child: Text("You have no contacts"),
          ),
        if (contactsList.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                Contact contactN = contactsList[index];
                return Slidable(
                  startActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _showModalBottomSheet(context, contactN.phoneNumber);
                        },
                        backgroundColor: const Color(0xFF21B7CA),
                        foregroundColor: Colors.white,
                        icon: Icons.message,
                        label: 'Call',
                      ),
                      SlidableAction(
                        onPressed: (context) {},
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.close,
                        label: 'Cancel',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          ref
                              .read(contactsProvider.notifier)
                              .deleteContact(contactN.phoneNumber);
                        },
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
                          style: const TextStyle(
                              color: Colors.white, fontSize: 25),
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
              itemCount: contactsList.length,
            ),
          ),
      ],
    );
  }
}
