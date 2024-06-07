import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                      // onPressed: () async {
                      //   Navigator.of(context).push(
                      //     MaterialPageRoute(
                      //       builder: (context) => const SearchScreen(),
                      //     ),
                      //   );
                      // },
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                        // CallKitParams callKitParams = CallKitParams(
                        //   id: DateTime.now().toString(),
                        //   nameCaller: 'Odufuwa Adebola',
                        //   appName: 'TextCall',
                        //   // avatar: 'https://i.pravatar.cc/100',

                        //   handle: '0123456789',
                        //   type: 0,
                        //   textAccept: 'Accept',
                        //   textDecline: 'Decline',
                        //   missedCallNotification: const NotificationParams(
                        //     showNotification: true,
                        //     isShowCallback: false,
                        //     subtitle: 'Missed Text Call',
                        //     // callbackText: 'Call back',
                        //   ),
                        //   duration: 20000,
                        //   extra: <String, dynamic>{'userId': 123},
                        //   headers: <String, dynamic>{
                        //     'apiKey': 'Abc@123!',
                        //     'platform': 'flutter'
                        //   },
                        //   android: const AndroidParams(
                        //     isCustomNotification: true,
                        //     isShowLogo: true,
                        //     ringtonePath: 'system_ringtone_default',
                        //     backgroundColor: '#36618e',
                        //     // backgroundUrl: 'https://i.pravatar.cc/500',
                        //     actionColor: '#4CAF50',
                        //     textColor: '#ffffff',
                        //     incomingCallNotificationChannelName:
                        //         "Incoming Call",
                        //     missedCallNotificationChannelName: "Missed Call",
                        //     isShowCallID: false,
                        //   ),
                        //   ios: const IOSParams(
                        //     iconName: 'CallKitLogo',
                        //     handleType: 'generic',
                        //     supportsVideo: true,
                        //     maximumCallGroups: 2,
                        //     maximumCallsPerCallGroup: 1,
                        //     audioSessionMode: 'default',
                        //     audioSessionActive: true,
                        //     audioSessionPreferredSampleRate: 44100.0,
                        //     audioSessionPreferredIOBufferDuration: 0.005,
                        //     supportsDTMF: true,
                        //     supportsHolding: true,
                        //     supportsGrouping: false,
                        //     supportsUngrouping: false,
                        //     ringtonePath: 'system_ringtone_default',
                        //   ),
                        // );
                        // await FlutterCallkitIncoming.showCallkitIncoming(
                        //     callKitParams);

                        // FlutterCallkitIncoming.onEvent
                        //     .listen((CallEvent? event) async {
                        //   switch (event!.event) {
                        //     case Event.actionCallIncoming:
                        //       final Map<String, dynamic> eventBody = event.body;
                        //       final activeCalls =
                        //           await FlutterCallkitIncoming.activeCalls();

                        //       debugPrint(
                        //           'active calls ${activeCalls[activeCalls.length - 1]}');

                        //       print(activeCalls[activeCalls.length - 1]
                        //           ['isAccepted']);

                        //       // print(eventBody);

                        //       // print(eventBody['number'].runtimeType);
                        //       // print('event body is ok');
                        //       // final Map myDataInEventBody = eventBody['extra'];
                        //       // print(
                        //       //     myDataInEventBody);

                        //       // final String faf =
                        //       //     myDataInEventBody['userId'].toString();
                        //       // print('Call incoming');

                        //       break;
                        //     case Event.actionCallStart:
                        //       break;
                        //     case Event.actionCallAccept:
                        //       final activeCalls =
                        //           await FlutterCallkitIncoming.activeCalls();

                        //       debugPrint(
                        //           'active calls ${activeCalls[activeCalls.length - 1]}');
                        //       final gin = DateTime.now()
                        //           .difference(DateTime.parse(
                        //               activeCalls[activeCalls.length - 1]
                        //                   ['id']))
                        //           .inSeconds;
                        //       print('active calls mkbhd $gin');
                        //       print(activeCalls[activeCalls.length - 1]
                        //           ['isAccepted']);

                        //       break;
                        //     case Event.actionCallDecline:
                        //       final url = Uri.https(
                        //           'text-call-backend.onrender.com',
                        //           'call/rejected/09000');
                        //       get(url);
                        //       print('call rejected');
                        //       break;
                        //     case Event.actionCallEnded:
                        //       break;
                        //     case Event.actionCallTimeout:
                        //       break;
                        //     case Event.actionCallCallback:
                        //       break;
                        //     case Event.actionCallToggleHold:
                        //       break;
                        //     case Event.actionCallToggleMute:
                        //       break;
                        //     case Event.actionCallToggleDmtf:
                        //       break;
                        //     case Event.actionCallToggleGroup:
                        //       break;
                        //     case Event.actionCallToggleAudioSession:
                        //       break;
                        //     case Event.actionDidUpdateDevicePushTokenVoip:
                        //       break;
                        //     case Event.actionCallCustom:
                        //       break;
                        //   }
                        // });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                            'messageJsonString',
                            jsonEncode({
                              0: {
                                'image': {
                                  'imagePaths': {
                                    'online': null,
                                    'local':
                                        '/data/user/0/com.example.text_call/app_flutter/messageWriter/images/42988be5-6046-45c8-b4b8-d83da587a84b6938616458256137263.jpg'
                                  }
                                }
                              },
                              1: {
                                'video': {
                                  'videoPaths': {
                                    'online': null,
                                    'local':
                                        '/data/user/0/com.example.text_call/app_flutter/messageWriter/videos/ba5cf4aa-5a6b-4245-b295-19800a51fecf4423616779087903428.mp4'
                                  }
                                }
                              }
                            }));
                        await prefs.setString(
                            'callerPhoneNumber', '+2349098875567');
                        await prefs.setString('messageType', 'complex');

                        createAwesomeNotification(
                          title: 'debugging skills is calling',
                          body: 'Might be urgent. Schrödinger\'s message',
                          notificationPurpose: NotificationPurpose.forCall,
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
                                  backgroundColor:
                                      Theme.of(context).brightness ==
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
