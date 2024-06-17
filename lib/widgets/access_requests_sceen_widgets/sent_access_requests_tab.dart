import 'package:flutter/material.dart';
import 'package:text_call/widgets/access_requests_sceen_widgets/sent_access_requests_card.dart';

class AccessRequestsSentTab extends StatelessWidget {
  const AccessRequestsSentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) => const SentAccessRequestsCard(),
    );
  }
}
