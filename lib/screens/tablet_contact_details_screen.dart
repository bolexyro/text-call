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

class TabletContactDetailsScreen extends ConsumerStatefulWidget {
  const TabletContactDetailsScreen({
    super.key,
    required this.contact,
  });
  final Contact contact;

  @override
  ConsumerState<TabletContactDetailsScreen> createState() =>
      _TabletContactDetailsScreenState();
}

class _TabletContactDetailsScreenState
    extends ConsumerState<TabletContactDetailsScreen> {
  final Map<Recent, bool> _expandedBoolsMap = {};

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

  void _goToSentMessageScreen(Message message) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SentMessageScreen(
        howSmsIsOpened: HowSmsIsOpened.notFromTerminatedToShowMessage,
        message: message,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final allRecents = ref.watch(recentsProvider);
    final recentsForThisContact =
        getRecentsForAContact(allRecents, widget.contact.phoneNumber);
    return Scaffold(
      appBar: AppBar(
         leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ContactCardWProfilePicStack(
                contact: widget.contact,
                width: MediaQuery.sizeOf(context).width * .425,
              ),
            ),
            if (recentsForThisContact.isEmpty)
              Expanded(
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      'Start conversing with ${widget.contact.name} to see your history.',
                      textAlign: TextAlign.center,
                    ),
                    const Icon(
                      Icons.history,
                      size: 110,
                      color: Colors.grey,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            if (recentsForThisContact.isNotEmpty)
              Expanded(
                child: GroupedListView(
                  order: GroupedListOrder.DESC,
                  shrinkWrap: true,
                  useStickyGroupSeparators: true,
                  stickyHeaderBackgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  elements: recentsForThisContact,
                  groupBy: (recentN) => DateTime(recentN.callTime.year,
                      recentN.callTime.month, recentN.callTime.day),
                  groupSeparatorBuilder: (DateTime groupHeaderDateTime) =>
                      Padding(
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
                          expandedContent: recentN.category !=
                                  RecentCategory.incomingRejected
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
                                  onPressed: () => sendAccessRequest(recentN),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Request access'),
                                ),
                          isExpanded: _expandedBoolsMap[recentN]!,
                          tileOnTapped: () =>
                              _changeTileExpandedStatus(recentN),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
