import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_info_card.dart';
import 'package:text_call/widgets/grouped_recents_list.dart';

class ContactDetailsPane extends ConsumerWidget {
  const ContactDetailsPane({
    super.key,
    this.contact,
    this.recent,
    required this.stackContainerWidths,
  });

  final Contact? contact;
  final Recent? recent;
  final double stackContainerWidths;

  void _goToSentMessageScreen(BuildContext context, Message message) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SentMessageScreen(
        howSmsIsOpened: HowSmsIsOpened
            .notFromTerminatedToShowMessageAfterAccessRequestGranted,
        message: message,
      ),
    ));
  }

  String _getFormattedCallTime(DateTime callTime) {
    final today = DateTime.now();

    final differenceInDays = today.difference(callTime).inDays;

    if (differenceInDays == 0) {
      return 'Today @${DateFormat.Hm().format(callTime)}';
    } else if (differenceInDays == 1) {
      return 'Yesterday @${DateFormat.Hm().format(callTime)}';
    } else {
      return '${DateFormat('dd-MM-yyyy').format(callTime)} @${DateFormat.Hm().format(callTime)}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (contact == null) {
      return Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          ContactInfoCard(
            contact: recent!.contact,
            recent: recent,
            width: stackContainerWidths,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            _getFormattedCallTime(recent!.callTime),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(recntCategoryStringMap[recent!.category]!),
          const SizedBox(
            height: 7,
          ),
          recent!.category != RecentCategory.incomingRejected
              ? ElevatedButton(
                  onPressed: () {
                    _goToSentMessageScreen(context, recent!.message);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Show message'),
                )
              : ElevatedButton(
                  onPressed: () => sendAccessRequest(recent!),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Request access'),
                ),
        ],
      );
    }
    final allRecents = ref.watch(recentsProvider);
    final recentsForAContact =
        getRecentsForAContact(allRecents, contact!.phoneNumber);
    return Column(
      children: [
        ContactInfoCard(
          contact: contact!,
          width: stackContainerWidths,
        ),
        const SizedBox(
          height: 20,
        ),
        if (recentsForAContact.isEmpty)
          Column(
            children: [
              Text(
                'Start conversing with ${contact!.name} to see your history.',
                textAlign: TextAlign.center,
              ),
              const Icon(
                Icons.history,
                size: 110,
                color: Colors.grey,
              ),
            ],
          ),
        if (recentsForAContact.isNotEmpty)
          Expanded(
            child: GroupedRecentsList(recents: recentsForAContact),
          ),
      ],
    );
  }
}