import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:text_call/models/complex_message.dart';
import 'package:text_call/models/regular_message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'package:text_call/screens/sent_message_screens/sms_not_from_terminaed.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/expandable_list_tile.dart';

class GroupedRecentsList extends StatefulWidget {
  const GroupedRecentsList({
    super.key,
    required this.recents,
  });

  final List<Recent> recents;
  @override
  State<GroupedRecentsList> createState() => _GroupedRecentsListState();
}

class _GroupedRecentsListState extends State<GroupedRecentsList> {
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

  void _goToSentMessageScreen(
      {required RegularMessage? regularMessage,
      required ComplexMessage? complexMessage}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SmsNotFromTerminated(
        howSmsIsOpened: HowSmsIsOpened
            .notFromTerminatedToShowMessageAfterAccessRequestGranted,
        complexMessage: complexMessage,
        regularMessage: regularMessage,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      order: GroupedListOrder.DESC,
      shrinkWrap: true,
      useStickyGroupSeparators: true,
      stickyHeaderBackgroundColor:
          Theme.of(context).colorScheme.primaryContainer,
      elements: widget.recents,
      groupBy: (recentN) => DateTime(
          recentN.callTime.year, recentN.callTime.month, recentN.callTime.day),
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
        _expandedBoolsMap[recentN] = _expandedBoolsMap.containsKey(recentN)
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
              expandedContent: recentN.canBeViewed
                  ? ElevatedButton(
                      onPressed: () {
                        _goToSentMessageScreen(
                          regularMessage: recentN.regularMessage,
                          complexMessage: recentN.complexMessage,
                        );
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
              tileOnTapped: () => _changeTileExpandedStatus(recentN),
            ),
          ],
        );
      },
    );
  }
}
