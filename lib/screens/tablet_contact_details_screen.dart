import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_info_card.dart';
import 'package:text_call/widgets/grouped_recents_list.dart';

class TabletContactDetailsScreen extends ConsumerWidget {
  const TabletContactDetailsScreen({
    super.key,
    required this.contact,
  });
  final Contact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRecents = ref.watch(recentsProvider);
    final recentsForThisContact =
        getRecentsForAContact(allRecents, contact.phoneNumber);
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
              child: ContactInfoCard(
                contact: contact,
                width: MediaQuery.sizeOf(context).width * .425,
              ),
            ),
            if (recentsForThisContact.isEmpty)
              Expanded(
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      'Start conversing with ${contact.name} to see your history.',
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
                child: GroupedRecentsList(recents: recentsForThisContact),
              ),
          ],
        ),
      ),
    );
  }
}
