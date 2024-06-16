import 'package:flutter/material.dart';
import 'package:text_call/widgets/access_requests_sceen_widgets/received_access_request_card.dart';

class AccessRequestsReceivedTab extends StatelessWidget {
  const AccessRequestsReceivedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) => const ReceivedAccessRequestCard(),
    );
  }
}
