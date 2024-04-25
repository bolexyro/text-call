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
  final Map<Contact, bool> _expandedBoolsMap = {};

  void _showAddContactDialog(context) async {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return const AddContact();
      },
    );
  }

  void _changeTileExpandedStatus(Contact contact) {
    setState(() {
      _expandedBoolsMap[contact] = !_expandedBoolsMap[contact]!;
      for (final Contact loopContact in _expandedBoolsMap.keys) {
        if (loopContact != contact && _expandedBoolsMap[loopContact] == true) {
          _expandedBoolsMap[loopContact] = false;
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
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('callMessage', 'callMessage');
                await prefs.setString('callerPhoneNumber', 'callerPhoneNumber');
                await prefs.setString('callerName', 'callerPhoneNumber');
                await prefs.setString(
                  'backgroundColor',
                  json.encode(
                    {
                      'alpha': 200,
                      'red': 90,
                      'green': 90,
                      'blue': 20,
                    },
                  ),
                );
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
              itemComparator: (element1, element2) =>
                  element1.name.compareTo(element2.name),
              itemBuilder: (context, contactN) {
                _expandedBoolsMap[contactN] =
                    _expandedBoolsMap.containsKey(contactN)
                        ? _expandedBoolsMap[contactN]!
                        : false;
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
                          isExpanded: _expandedBoolsMap[contactN]!,
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
                            _changeTileExpandedStatus(contactN);
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
