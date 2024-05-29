import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/screens/search_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/dialogs/confirm_delete_dialog.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_letter_avatar.dart';
import 'package:text_call/widgets/expandable_list_tile.dart';

class ContactsList extends ConsumerStatefulWidget {
  const ContactsList({
    super.key,
    required this.onContactSelected,
    required this.screen,
    required this.scaffoldKey,
  });

  final void Function(Contact selectedContact) onContactSelected;
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
      builder: (context) => ConfirmDeleteDialog(
        title: 'Delete Contact - ${contact.name}',
      ),
    );
    if (toDelete != true) {
      return;
    }
    ref.read(contactsProvider.notifier).deleteContact(contact.phoneNumber);
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

    final animatedContainerContent = animatedContainerHeight == bigHeight
        // i am using this singlechildScrollView around the column because, if you don't you'd be getting errors.
        ? SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        widget.scaffoldKey.currentState!.openDrawer();
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/hamburger-menu.svg',
                        height: 30,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).iconTheme.color ?? Colors.grey,
                            BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Contacts',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      '${contactsList.length} contacts with phone number',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Row(
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
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 15, 5, 15),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    widget.scaffoldKey.currentState!.openDrawer();
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/hamburger-menu.svg',
                    height: 30,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).iconTheme.color ?? Colors.grey,
                        BlendMode.srcIn),
                  ),
                ),
                Text(
                  'Contacts',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
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
          );
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: animatedContainerHeight,
          child: animatedContainerContent,
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
                ],
              ),
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
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is OverscrollNotification) {
                    if (_scrollController.offset <=
                            _scrollController.position.minScrollExtent &&
                        !_scrollController.position.outOfRange) {
                      setState(() {
                        animatedContainerHeight = bigHeight;
                      });
                    }
                  }
                  if (notification is UserScrollNotification) {
                    if (notification.direction == ScrollDirection.forward) {
                      if (_scrollController.offset <=
                              _scrollController.position.minScrollExtent &&
                          !_scrollController.position.outOfRange) {
                        setState(() {
                          animatedContainerHeight = bigHeight;
                        });
                      }
                    } else if (notification.direction ==
                        ScrollDirection.reverse) {
                      setState(() {
                        animatedContainerHeight = smallHeight;
                      });
                    }
                  }
                  // Returning null (or false) to
                  // "allow the notification to continue to be dispatched to further ancestors".
                  return false;
                },
                child: GroupedListView(
                  controller: _scrollController,
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
                    return SwipeTo(
                      onRightSwipe: (_) {
                        showMessageWriterModalSheet(
                          context: context,
                          calleePhoneNumber: contactN.phoneNumber,
                          calleeName: contactN.name,
                        );
                      },
                      rightSwipeWidget: Container(
                        color: const Color(0xFF21B7CA),
                        width: 180,
                        height: 70,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/message-ring.svg',
                            height: 30,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          ),
                        ),
                      ),
                      onLeftSwipe: (_) {
                        _showDeleteDialog(context, contactN);
                      },
                      offsetDx: .5,
                      leftSwipeWidget: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,

                        child: Container(
                          width: 200,
                          height: 70,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.errorContainer
                              : Theme.of(context).colorScheme.error,
                          child: const Icon(
                            Icons.delete,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
              ),
            ),
          ),
      ],
    );
  }
}
