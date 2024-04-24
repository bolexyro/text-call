import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/confirm_delete_dialog.dart';
import 'package:text_call/widgets/contacts_screen_widgets/add_contact.dart';
import 'package:text_call/widgets/expandable_list_tile.dart';

class ContactsList extends ConsumerStatefulWidget {
  const ContactsList({
    super.key,
    required this.onContactSelected,
    required this.screen,
  });

  final void Function(Contact selectedContact) onContactSelected;
  final Screen screen;

  @override
  ConsumerState<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends ConsumerState<ContactsList> {
  final List<bool> _listExpandedBools = [];

  void _showAddContactDialog(context) async {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return const AddContact();
      },
    );
  }

  void _changeTileExpandedStatus(index) {
    setState(() {
      _listExpandedBools[index] = !_listExpandedBools[index];
      for (int i = 0; i < _listExpandedBools.length; i++) {
        if (i != index && _listExpandedBools[i] == true) {
          _listExpandedBools[i] = false;
        }
      }
    });
  }

  void _showDeleteDialog(BuildContext context, Contact contact) async {
    final bool? toDelete = await showAdaptiveDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        contactName: contact.name,
      ),
    );
    if (toDelete != true) {
      return;
    }
    ref.read(contactsProvider.notifier).deleteContact(contact.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final List<Contact> contactsList = ref.watch(contactsProvider);
    // final contactsList = [
    //   const Contact(name: 'Bolexyro', phoneNumber: '09027929326'),
    //   const Contact(name: 'Mom', phoneNumber: '07034744820'),
    //   const Contact(name: 'Mosh', phoneNumber: '07034744820'),
    //   const Contact(name: 'Giannis', phoneNumber: '07034744820'),
    //   const Contact(name: 'Banjo', phoneNumber: '07034744820'),
    //   const Contact(name: 'LeBron', phoneNumber: '07034744820'),
    //   const Contact(name: 'Samuel', phoneNumber: '07034744820'),
    //   const Contact(name: 'Wisdom', phoneNumber: '07034744820'),
    //   const Contact(name: 'Oba', phoneNumber: '07034744820'),
    //   const Contact(name: 'Someone', phoneNumber: '07034744820'),
    // ];

    contactsList.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return Column(
      children: [
        const SizedBox(
          height: 45,
        ),
        const Text(
          'Contacts',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            '${contactsList.length} contacts with phone number',
            textAlign: TextAlign.center,
          ),
        ),
        Row(
          children: [
            const Spacer(),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                _showAddContactDialog(context);
              },
              icon: const Icon(Icons.person_add),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () async {
                print('......');
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('callMessage', 'callMessage');
                await prefs.setString('callerPhoneNumber', 'callerPhoneNumber');
                await prefs.setString('callerName', 'callerPhoneNumber');
                await prefs.setString(
                  'backgroundColor',
                  json.encode(
                      {'alpha': 200, 'red': 100, 'blue': 90, 'green': 20}),
                );
                print('sett');
                createAwesomeNotification(title: 'Bolexyro');
              },
              icon: const Icon(Icons.search),
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
            child: GroupedListView(
              useStickyGroupSeparators: true,
              floatingHeader: true,
              stickyHeaderBackgroundColor:
                  Theme.of(context).colorScheme.secondary,
              elements: contactsList,
              groupBy: (contactN) => contactN.name[0],
              groupSeparatorBuilder: (String groupHeader) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  groupHeader,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              itemBuilder: (context, contactN) {
                int index = contactsList.indexOf(contactN);
                _listExpandedBools.add(false);
                return Slidable(
                  startActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          showMessageWriterModalSheet(
                              context: context,
                              calleePhoneNumber: contactN.phoneNumber,
                              calleeName: contactN.name);
                        },
                        backgroundColor: const Color(0xFF21B7CA),
                        foregroundColor: Colors.white,
                        icon: Icons.message,
                        label: 'Call',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _showDeleteDialog(context, contactN);
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: widget.screen == Screen.phone
                      ? ExpandableListTile(
                          isExpanded: _listExpandedBools[index],
                          title: Text(contactN.name),
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
                          tileOnTapped: () {
                            _changeTileExpandedStatus(index);
                          },
                          expandedContent: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Mobile ${contactN.localPhoneNumber}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showMessageWriterModalSheet(
                                        calleeName: contactN.name,
                                        calleePhoneNumber: contactN.phoneNumber,
                                        context: context,
                                      );
                                    },
                                    icon: const Icon(Icons.message),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      widget.onContactSelected(contactN);
                                    },
                                    icon: const Icon(Icons.info_outlined),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            ListTile(
                              title: Text(contactN.name),
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
                              onTap: () => widget.onContactSelected(contactN),
                            ),
                            const Divider(
                              indent: 45,
                              endIndent: 15,
                            ),
                          ],
                        ),
                );
              },
              // itemCount: contactsList.length,
            ),
          ),
      ],
    );
  }
}
