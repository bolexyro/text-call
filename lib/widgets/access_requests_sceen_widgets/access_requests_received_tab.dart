import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/utils/crud.dart';
import 'package:text_call/widgets/access_requests_sceen_widgets/received_access_request_card.dart';

class AccessRequestsReceivedTab extends ConsumerStatefulWidget {
  const AccessRequestsReceivedTab({super.key});

  @override
  ConsumerState<AccessRequestsReceivedTab> createState() =>
      _AccessRequestsReceivedTabState();
}

class _AccessRequestsReceivedTabState
    extends ConsumerState<AccessRequestsReceivedTab> {
  Future<List<Recent>>
      loadCorrespondingRecentsForReceivedAccessRequests() async {
    final allAccessRquestsReceived =
        await readAccessRequestsFromDb(isSent: false);

    // i will have the recent id in all accessrequests received, so from there i will need to get the name of the person, can be gotten through the recentsprovider .where (id = id)
    // then i will get the name of the person, and the message, so when they tap they see that message
    final allRecentIdsInAccessRequests =
        allAccessRquestsReceived.map((row) => row['recentId']);
    return ref
        .read(recentsProvider)
        .where(
          (recent) => allRecentIdsInAccessRequests.contains(recent.id),
        )
        .toList();
  }

  late Future<List<Recent>> correspondingRecentsForReceivedAccessRequests;

  @override
  void initState() {
    correspondingRecentsForReceivedAccessRequests =
        loadCorrespondingRecentsForReceivedAccessRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: correspondingRecentsForReceivedAccessRequests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          );
        }

        final correspondingRecentsForReceivedAccessRequests = snapshot.data!;
        return correspondingRecentsForReceivedAccessRequests.isEmpty
            ?  Center(
                child:
                    Lottie.asset(
                        'assets/animations/empty_box.json',
                        repeat: false,
                      )
                    // Text('hello'),
              )
            : ListView.builder(
                itemCount: correspondingRecentsForReceivedAccessRequests.length,
                itemBuilder: (context, index) => ReceivedAccessRequestCard(
                  recent: correspondingRecentsForReceivedAccessRequests[index],
                ),
              );
      },
    );
  }
}
