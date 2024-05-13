import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_card_w_profile_pic_stack.dart';
import 'package:text_call/widgets/expandable_list_tile.dart';

enum Purpose { forContact, forRecent }

class ContactDetails extends ConsumerStatefulWidget {
  const ContactDetails({
    super.key,
    this.contact,
    this.recent,
    required this.stackContainerWidths,
  });

  final Contact? contact;
  final Recent? recent;
  final double stackContainerWidths;

  @override
  ConsumerState<ContactDetails> createState() => _ContactDetailsState();
}

class _ContactDetailsState extends ConsumerState<ContactDetails> {
  final Map<Recent, bool> _expandedBoolsMap = {};

  void _goToSentMessageScreen(Message message) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SentMessageScreen(
        howSmsIsOpened: HowSmsIsOpened.notFromTerminatedToShowMessage,
        message: message,
      ),
    ));
  }

  String _groupHeaderText(DateTime headerDateTime) {
    if (DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day) ==
        DateTime(
            headerDateTime.year, headerDateTime.month, headerDateTime.day)) {
      return "Today";
    } else if (DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day - 1) ==
        DateTime(
            headerDateTime.year, headerDateTime.month, headerDateTime.day)) {
      return 'Yesterday';
    }
    return DateFormat('d MMMM').format(headerDateTime);
  }

  void _changeTileExpandedStatus(Recent recent) {
    setState(() {
      _expandedBoolsMap[recent] = !_expandedBoolsMap[recent]!;
      for (final Recent loopRecent in _expandedBoolsMap.keys) {
        if (loopRecent != recent && _expandedBoolsMap[loopRecent] == true) {
          _expandedBoolsMap[loopRecent] = false;
        }
      }
    });
  }

  String _getFormattedCallTime(DateTime callTime) {
    final today = DateTime.now();

    final differenceInDays = today.difference(callTime).inDays;

    if (differenceInDays == 0) {
      return 'Today @${DateFormat.Hm().format(callTime)}';
    } else if (differenceInDays == 1) {
      return 'Yesterday @${DateFormat.Hm().format(callTime)}';
    } else {
      return '${DateFormat('dd-MM-yyyy').format(callTime)} @${DateFormat.Hm().format(callTime)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final purpose =
        widget.contact == null ? Purpose.forRecent : Purpose.forContact;

    if (purpose == Purpose.forRecent) {
      return Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          ContactCardWProfilePicStack(
            contact: widget.recent!.contact,
            recent: widget.recent,
            transparentAndNonTransparentWidth: widget.stackContainerWidths,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            _getFormattedCallTime(widget.recent!.callTime),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(recntCategoryStringMap[widget.recent!.category]!),
          const SizedBox(
            height: 7,
          ),
          widget.recent!.category != RecentCategory.incomingRejected
              ? ElevatedButton(
                  onPressed: () {
                    _goToSentMessageScreen(widget.recent!.message);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Show message'),
                )
              : ElevatedButton(
                  onPressed: () => sendAccessRequest(widget.recent!),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Request access'),
                ),
        ],
      );
    }
    final allRecents = ref.watch(recentsProvider);
    final recentsForAContact =
        getRecentsForAContact(allRecents, widget.contact!.phoneNumber);
    return Column(
      children: [
        ContactCardWProfilePicStack(
          contact: widget.contact!,
          transparentAndNonTransparentWidth: widget.stackContainerWidths,
        ),
        const SizedBox(
          height: 20,
        ),
        if (recentsForAContact.isEmpty)
          Column(
            children: [
              Text(
                'Start conversing with ${widget.contact!.name} to see your history.',
                textAlign: TextAlign.center,
              ),
              const Icon(
                Icons.history,
                size: 110,
                color: Colors.grey,
              ),
            ],
          ),
        if (recentsForAContact.isNotEmpty)
          Expanded(
            child: GroupedListView(
              order: GroupedListOrder.DESC,
              shrinkWrap: true,
              useStickyGroupSeparators: true,
              stickyHeaderBackgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              elements: recentsForAContact,
              groupBy: (recentN) => DateTime(recentN.callTime.year,
                  recentN.callTime.month, recentN.callTime.day),
              groupSeparatorBuilder: (DateTime groupHeaderDateTime) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _groupHeaderText(groupHeaderDateTime),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              itemComparator: (element1, element2) =>
                  element1.callTime.compareTo(element2.callTime),
              itemBuilder: (context, recentN) {
                _expandedBoolsMap[recentN] =
                    _expandedBoolsMap.containsKey(recentN)
                        ? _expandedBoolsMap[recentN]!
                        : false;
                return Column(
                  children: [
                    ExpandableListTile(
                      justARegularListTile: false,
                      leading: recentCategoryIconMap[recentN.category]!,
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat.Hm().format(recentN.callTime)),
                          Text(recntCategoryStringMap[recentN.category]!),
                        ],
                      ),
                      expandedContent:
                          recentN.category != RecentCategory.incomingRejected
                              ? ElevatedButton(
                                  onPressed: () {
                                    _goToSentMessageScreen(recentN.message);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Show Message'),
                                )
                              : ElevatedButton(
                                  onPressed: () =>
                                      sendAccessRequest(widget.recent!),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Request access'),
                                ),
                      isExpanded: _expandedBoolsMap[recentN]!,
                      tileOnTapped: () => _changeTileExpandedStatus(recentN),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
