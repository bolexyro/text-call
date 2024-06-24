import 'package:flutter/material.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/received_access_requests_provider.dart';
import 'package:text_call/widgets/sent_message_screen_widgets.dart';
import 'package:text_call/screens/sent_message_screens/sms_not_from_terminaed.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_letter_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReceivedAccessRequestCard extends ConsumerWidget {
  const ReceivedAccessRequestCard({
    super.key,
    required this.recent,
  });

  final Recent recent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SmsNotFromTerminated(
            isRecentOutgoing: recentIsOutgoing(recent.category),
            howSmsIsOpened:
                HowSmsIsOpened.notFromTerminatedToJustDisplayMessage,
            regularMessage: recent.regularMessage,
            complexMessage: recent.complexMessage,
            recentCallTime: recent.callTime,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? makeColorLighter(Theme.of(context).primaryColor, 20)
              : const Color.fromARGB(255, 176, 208, 235),
          border: Border.all(width: 1),
        ),
        height: 70,
        child: Row(
          children: [
            const SizedBox(
              width: 29,
            ),
            recent.contact.imagePath == null
                ? ContactLetterAvatar(contactName: recent.contact.name)
                : ContactAvatarCircle(
                    avatarRadius: 20,
                    imagePath: recent.contact.imagePath,
                  ),
            const SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From ${recent.contact.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Click to view'),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                ref
                    .read(receivedAccessRequestsProvider.notifier)
                    .removeReceivedAccessRequest(recent.id);

                sendAccessRequestStatus(
                  accessRequestStatus: AccessRequestStatus.granted,
                  payload: {
                    'requesterPhoneNumber': recent.contact.phoneNumber,
                    'recentId': recent.id,
                  },
                );
              },
              child: Container(
                decoration: const ShapeDecoration(
                  shape: CircleBorder(
                    side: BorderSide(width: 1, color: Colors.green),
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 25,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                sendAccessRequestStatus(
                  accessRequestStatus: AccessRequestStatus.denied,
                  payload: {
                    'requesterPhoneNumber': recent.contact.phoneNumber,
                    'recentId': recent.id,
                  },
                );
                ref
                    .read(receivedAccessRequestsProvider.notifier)
                    .removeReceivedAccessRequest(recent.id);
              },
              child: Container(
                decoration: const ShapeDecoration(
                  shape: CircleBorder(
                    side: BorderSide(width: 1, color: Colors.red),
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: const Icon(
                  Icons.close,
                  size: 25,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}
