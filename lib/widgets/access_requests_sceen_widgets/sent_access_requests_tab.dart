import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/received_access_requests_provider.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/access_requests_sceen_widgets/sent_access_requests_card.dart';

class SentAccessRequestsTab extends ConsumerStatefulWidget {
  const SentAccessRequestsTab({
    super.key,
    required this.allSentAccessRequestsRawFromDb,
  });
  final List allSentAccessRequestsRawFromDb;

  @override
  ConsumerState<SentAccessRequestsTab> createState() =>
      _AccessRequestsSentTabState();
}

class _AccessRequestsSentTabState extends ConsumerState<SentAccessRequestsTab> {
  bool _isRefreshing = false;
  late Map<String, String> recentIdToTimeMap;

  @override
  void initState() {
    super.initState();
    recentIdToTimeMap = {
      for (var item in widget.allSentAccessRequestsRawFromDb)
        item['recentId']: item['time']
    };
  }

  String? findTimeByRecentId(String recentIdToFind) {
    return recentIdToTimeMap[recentIdToFind];
  }

  @override
  Widget build(BuildContext context) {
    // Get all the recent ids, then query the recents ref, and get all of the recents belonging to that id
    // And for every id, we check the can be viewed and pending status to determine its status
    final allRecentIdsInSentAccessRequests =
        widget.allSentAccessRequestsRawFromDb.map((row) => row['recentId']);
    final recentsWeNeed = ref.read(recentsProvider).where(
      (recent) {
        if (recent.category == RecentCategory.outgoingAccepted ||
            recent.category == RecentCategory.outgoingIgnored ||
            recent.category == RecentCategory.outgoingUnreachable ||
            recent.category == RecentCategory.outgoingRejected) {
          return false;
        }
        return allRecentIdsInSentAccessRequests.contains(recent.id);
      },
    ).toList();

    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            _isRefreshing
                ? Container(
                    margin: const EdgeInsets.all(8),
                    height: kIconHeight,
                    width: kIconHeight,
                    child: const CircularProgressIndicator(),
                  )
                : IconButton(
                    onPressed: () async {
                      setState(() {
                        _isRefreshing = true;
                      });
                      await ref
                          .read(receivedAccessRequestsProvider.notifier)
                          .loadPendingReceivedAccessRequests(ref);
                      setState(() {
                        _isRefreshing = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                  ),
          ],
        ),
        Expanded(
          child: recentsWeNeed.isEmpty
              ? Center(
                  child: Lottie.asset(
                    'assets/animations/empty_box.json',
                    repeat: false,
                  ),
                )
              : GroupedListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  useStickyGroupSeparators: true,
                  floatingHeader: true,
                  stickyHeaderBackgroundColor:
                      Theme.of(context).colorScheme.secondary,
                  elements: recentsWeNeed,
                  groupBy: (recentN) => DateTime(recentN.callTime.year,
                      recentN.callTime.month, recentN.callTime.day),
                  groupSeparatorBuilder: (DateTime groupHeaderDateTime) =>
                      Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      groupHeaderText(groupHeaderDateTime),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  order: GroupedListOrder.DESC,
                  itemComparator: (element1, element2) =>
                      element1.callTime.compareTo(element2.callTime),
                  itemBuilder: (context, recentN) => SentAccessRequestsCard(
                    recent: recentN,
                    sentTime: DateTime.parse(
                      findTimeByRecentId(recentN.id)!,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
