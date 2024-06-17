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
    
    state = ref
        .read(recentsProvider)
        .where(
          (recent) => allRecentIdsInAccessRequests.contains(recent.id),
        )
        .toList();
  }

  Future<void> removeReceivedAccessRequest(String recentId) async{
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
