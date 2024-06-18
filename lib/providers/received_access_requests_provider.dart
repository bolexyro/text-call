import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/utils/crud.dart';

class ReceivedAccessRequestsProviderNotifier
    extends StateNotifier<List<Recent>> {
  ReceivedAccessRequestsProviderNotifier() : super([]);

  Future<void> loadPendingReceivedAccessRequests(WidgetRef ref) async {
    // the only why we need ref here is so that we can get the recents corresponding to the recent ids we have
    final allAccessRquestsReceived =
        await readAccessRequestsFromDb(isSent: false);

    // i will have the recent id in all accessrequests received, so from there i will need to get the name of the person, can be gotten through the recentsprovider .where (id = id)
    // then i will get the name of the person, and the message, so when they tap they see that message
    final allRecentIdsInAccessRequests =
        allAccessRquestsReceived.map((row) => row['recentId']);

    // this would be kinda problematic when you are the one that called yourself. And your reject it. Lemme explain
    // when you call yourself, there would be 2 entries in the db with the same recent id. The outgoing and the incoming.
    // So, in the access requests tab, there would also be 2 entries. but you can eliminate that by doing a to set and then a to list.

    // the duplicate is in the recents table which is not a mistake.
    // so when you do allrecentidsinaccessrequests.contains(recent.id) and we are iterating over the duplicates in the recents table,
    // the above would return true multiple times for when we call ourselves.
    state = ref
        .read(recentsProvider)
        .where(
          (recent) {
            if (recent.category == RecentCategory.incomingAccepted || recent.category == RecentCategory.incomingIgnored || recent.category == RecentCategory.incomingRejected ){
              return false;
            }
            return allRecentIdsInAccessRequests.contains(recent.id);
          },
        )
        .toList();
  }

  Future<void> removeReceivedAccessRequest(String recentId) async {
    state = List.from(state)
      ..removeWhere(
        (recent) => recent.id == recentId,
      );
    deleteAccessRequestFromDb(recentId: recentId);
  }
}

final receivedAccessRequestsProvider =
    StateNotifierProvider<ReceivedAccessRequestsProviderNotifier, List<Recent>>(
  (ref) => ReceivedAccessRequestsProviderNotifier(),
);
