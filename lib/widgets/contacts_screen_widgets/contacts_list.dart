import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/confirm_delete_dialog.dart';
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
                showAddContactDialog(context);
              },
              icon: const Icon(Icons.person_add),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('callMessage', 'callMessage');
                await prefs.setString('callerPhoneNumber', '+2349098875567');
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
                prefs.setString('recentId', '2024-04-28 22:10:11.836578');
                createAwesomeNotification(
                    title: 'Bolexyro is asking permission to see a message.',
                    notificationPurpose: NotificationPurpose.forAccessRequest,
                    body: 'Which message? Click to find out.');
              },
              icon: const Icon(Icons.search),
            ),
            const SizedBox(width: 10),
          ],
        ),
        if (contactsList.isEmpty)
          Expanded(
            child: LiquidPullToRefresh(
              color: Theme.of(context).colorScheme.primaryContainer,
              backgroundColor: Colors.white,
              showChildOpacityTransition: false,
              onRefresh: () => Future.delayed(const Duration(seconds: 0)),
              height: MediaQuery.sizeOf(context).width < 520 ? 120 : 80,
              animSpeedFactor: 2.3,
              springAnimationDurationInMilliseconds: 600,
              child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(
                      height: 30,
                    ),
                    Center(child: Text("You have no contacts")),
                  ]),
            ),
          ),
        if (contactsList.isNotEmpty)
          Expanded(
            child: LiquidPullToRefresh(
              color: Theme.of(context).colorScheme.primaryContainer,
              backgroundColor: Colors.white,
              showChildOpacityTransition: false,
              onRefresh: () => Future.delayed(const Duration(seconds: 0)),
              height: MediaQuery.sizeOf(context).width < 520 ? 120 : 80,
              animSpeedFactor: 2.3,
              springAnimationDurationInMilliseconds: 600,
              child: GroupedListView(
                physics: const AlwaysScrollableScrollPhysics(),

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
                        CustomSlidableAction(
                          onPressed: (context) async {
                            await showMessageWriterModalSheet(
                                context: context,
                                calleePhoneNumber: contactN.phoneNumber,
                                calleeName: contactN.name);
                          },
                          backgroundColor: const Color(0xFF21B7CA),
                          foregroundColor: Colors.white,
                          child: SvgPicture.asset(
                            'assets/icons/message-ring.svg',
                            height: 30,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          ),
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const BehindMotion(),
                      children: [
                        CustomSlidableAction(
                          onPressed: (context) {
                            _showDeleteDialog(context, contactN);
                          },
                          backgroundColor: const Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          child: const Icon(
                            Icons.delete,
                            size: 30,
                          ),
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
                                      onPressed: () async {
                                        await showMessageWriterModalSheet(
                                          calleeName: contactN.name,
                                          calleePhoneNumber:
                                              contactN.phoneNumber,
                                          context: context,
                                        );
                                      },
                                      icon: SvgPicture.asset(
                                        'assets/icons/message-ring.svg',
                                        height: 24,
                                        colorFilter: ColorFilter.mode(
                                          Theme.of(context).iconTheme.color!,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        widget.onContactSelected(contactN);
                                      },
                                      icon: Icon(
                                        Icons.info_outlined,
                                        color:
                                            Theme.of(context).iconTheme.color!,
                                      ),
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
          ),
      ],
    );
  }
}
