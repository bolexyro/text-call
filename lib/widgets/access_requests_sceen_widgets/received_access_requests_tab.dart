import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';
import 'package:text_call/providers/received_access_requests_provider.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/access_requests_sceen_widgets/received_access_request_card.dart';

class AccessRequestsReceivedTab extends ConsumerStatefulWidget {
  const AccessRequestsReceivedTab({super.key});

  @override
  ConsumerState<AccessRequestsReceivedTab> createState() =>
      _AccessRequestsReceivedTabState();
}

class _AccessRequestsReceivedTabState
    extends ConsumerState<AccessRequestsReceivedTab> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final recentsForReceivedAccessRequests =
        ref.watch(receivedAccessRequestsProvider);
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
          child: recentsForReceivedAccessRequests.isEmpty
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
                  elements: recentsForReceivedAccessRequests,
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
                  itemBuilder: (context, recentN) =>
                      ReceivedAccessRequestCard(recent: recentN),
                ),
        ),
      ],
    );
  }
}
