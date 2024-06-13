import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
    //       name: 'Cola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Dola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Bola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Fola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Kola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Wola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Tola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Sola', phoneNumber: '+2349027929326', imagePath: null),
    //   const Contact(
    //       name: 'Lola', phoneNumber: '+2349027929326', imagePath: null),
    // ];

    return Column(
      children: [
        Column(
          children: [
            Stack(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: IconButton(
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
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Contacts',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${contactsList.length} ${contactsList.length == 1 ? 'contact' : 'contacts'} with phone number',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      ),
                      child: Hero(
                        tag: 'searchBarTag',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: SizedBox(
                            height: 66,
                            child: Card(
                              elevation: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? 10
                                  : 3,
                              color: makeColorLighter(
                                  Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer,
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? 10
                                      : -10),
                              shape: const StadiumBorder(),
                              child: const Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 24.0, right: 27.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Spacer(),
                                      Icon(Icons.close),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            onPressed: () {
                              showAddContactDialog(context);
                            },
                            icon: const Icon(Icons.person_add),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(),
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
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
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
                                backgroundColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Theme.of(context)
                                        .colorScheme
                                        .errorContainer
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
            ),
          ),
      ],
    );
  }
}
