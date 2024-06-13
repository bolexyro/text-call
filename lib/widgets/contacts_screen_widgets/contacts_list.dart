import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/screens/search_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/dialogs/confirm_dialog.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_letter_avatar.dart';
import 'package:text_call/widgets/expandable_list_tile.dart';

class ContactsList extends ConsumerStatefulWidget {
  const ContactsList({
    super.key,
    required this.onContactSelected,
    required this.screen,
    required this.scaffoldKey,
    required this.onContactDeleted,
  });

  final void Function(Contact selectedContact) onContactSelected;
  final void Function(Contact deletedContact) onContactDeleted;
  final Screen screen;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  ConsumerState<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends ConsumerState<ContactsList> {
  final Map<Contact, bool> _expandedBoolsMap = {};
  final ScrollController _scrollController = ScrollController();
  double bigHeight = 200;
  double smallHeight = 70;
  late double animatedContainerHeight;

  @override
  void initState() {
    animatedContainerHeight = bigHeight;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      builder: (context) => ConfirmDialog(
        title: 'Delete Contact - ${contact.name}',
        subtitle: 'This action cannot be undone',
        mainButtonText: 'Delete',
      ),
    );
    if (toDelete != true) {
      return;
    }
    ref.read(contactsProvider.notifier).deleteContact(ref, contact.phoneNumber);
    widget.onContactDeleted(contact);
  }

  Widget withOrWithoutHero(contact) {
    return widget.screen == Screen.phone
        ? Hero(
            tag: contact.phoneNumber,
            child: ContactAvatarCircle(
              avatarRadius: 20,
              imagePath: contact.imagePath,
            ),
          )
        : ContactAvatarCircle(
            avatarRadius: 20,
            imagePath: contact.imagePath,
          );
  }

  @override
  Widget build(BuildContext context) {
    final List<Contact> contactsList = ref.watch(contactsProvider);
    // final List<Contact> contactsList = [
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    // ];

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          delegate: MySliverAppBar(
              expandedHeight: 200,
              noContactsText:
                  '${contactsList.length} contacts with phone number'),
          pinned: true,
        ),
        SliverGroupedListView(
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
                    onPressed: (context) {
                      showMessageWriterModalSheet(
                          context: context,
                          calleePhoneNumber: contactN.phoneNumber,
                          calleeName: contactN.name);
                    },
                    backgroundColor: const Color(0xFF21B7CA),
                    foregroundColor: Colors.white,
                    child: SvgPicture.asset(
                      'assets/icons/message-ring.svg',
                      height: 30,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
              endActionPane: contactN.isMyContact
                  ? null
                  : ActionPane(
                      motion: const BehindMotion(),
                      children: [
                        CustomSlidableAction(
                          onPressed: (context) {
                            _showDeleteDialog(context, contactN);
                          },
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.errorContainer
                                  : Theme.of(context).colorScheme.error,
                          child: SvgPicture.asset(
                            'assets/icons/delete.svg',
                            height: 30,
                          ),
                        ),
                      ],
                    ),
              child: ExpandableListTile(
                justARegularListTile:
                    widget.screen == Screen.phone ? false : true,
                isExpanded: _expandedBoolsMap[contactN]!,
                title: Text(contactN.name),
                leading: GestureDetector(
                  onTap: () {
                    widget.onContactSelected(contactN);
                  },
                  child: contactN.imagePath != null
                      ? withOrWithoutHero(contactN)
                      : ContactLetterAvatar(contactName: contactN.name),
                ),
                tileOnTapped: () {
                  if (widget.screen == Screen.phone) {
                    _changeTileExpandedStatus(contactN);
                    return;
                  }
                  widget.onContactSelected(contactN);
                },
                expandedContent: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Mobile ${contactN.localPhoneNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            showMessageWriterModalSheet(
                              calleeName: contactN.name,
                              calleePhoneNumber: contactN.phoneNumber,
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
                            color: Theme.of(context).iconTheme.color!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          // itemCount: contactsList.length,
        ),
      ],
    );
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  MySliverAppBar({
    required this.expandedHeight,
    required this.noContactsText,
  });

  final double expandedHeight;
  final String noContactsText;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    print(shrinkOffset);
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Container(
          alignment: Alignment.bottomRight,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: () {
                  showAddContactDialog(context);
                },
                icon: const Icon(Icons.person_add),
              ),
              IconButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Opacity(
            opacity: (1 - shrinkOffset / expandedHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Contacts',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(noContactsText),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 45),
          child: Opacity(
            opacity: shrinkOffset < 150 ? 0 : shrinkOffset / expandedHeight,
            child: Text(
              'Contacts',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: () {
              // widget.scaffoldKey.currentState!.openDrawer();
            },
            icon: SvgPicture.asset(
              'assets/icons/hamburger-menu.svg',
              height: 30,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color ?? Colors.grey,
                  BlendMode.srcIn),
            ),
          ),
        )
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
