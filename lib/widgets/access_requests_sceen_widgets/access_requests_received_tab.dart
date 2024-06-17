import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:text_call/utils/crud.dart';
import 'package:text_call/widgets/access_requests_sceen_widgets/received_access_request_card.dart';

class AccessRequestsReceivedTab extends StatelessWidget {
  const AccessRequestsReceivedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final allAccessRquestsReceivedFuture =
        readAccessRequestsFromDb(isSent: false);
    return FutureBuilder(
        future: allAccessRquestsReceivedFuture,
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

          final allAccessRquestsReceived = snapshot.data!;
          return allAccessRquestsReceived.isEmpty
              ? Lottie.asset(
                  'assets/animations/empty_box.json',
                  repeat: false,
                )
              : ListView.builder(
                  itemCount: allAccessRquestsReceived.length,
                  itemBuilder: (context, index) =>
                      const ReceivedAccessRequestCard(),
                );
        });
  }
}
