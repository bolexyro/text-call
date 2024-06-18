import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/screens/sent_message_screen.dart';
import 'package:text_call/screens/sent_message_screens/sms_not_from_terminaed.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_letter_avatar.dart';

class SentAccessRequestsCard extends StatelessWidget {
  const SentAccessRequestsCard({
    super.key,
    required this.recent,
  });

  final Recent recent;

  @override
  Widget build(BuildContext context) {
    final String status = recent.canBeViewed
        ? 'Accepted'
        : recent.accessRequestPending
            ? 'Pending'
            : 'Rejected';
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SmsNotFromTerminated(
            howSmsIsOpened:
                HowSmsIsOpened.notFromTerminatedToJustDisplayMessage,
            regularMessage: recent.regularMessage,
            complexMessage: recent.complexMessage,
            recentCallTime: recent.callTime,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(10),
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
                    avatarRadius: 20, imagePath: recent.contact.imagePath),
            const SizedBox(
              width: 20,
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'To Bolexyro',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Click to view'),
              ],
            ),
            const Spacer(),
            Text(
              'Status: $status',
              style: const TextStyle(color: Colors.orange),
            ),
            const SizedBox(
              width: 10,
            ),
            const SentAccessRequestsCardMenuAnchor(),
          ],
        ),
      ),
    );
  }
}

class SentAccessRequestsCardMenuAnchor extends StatelessWidget {
  const SentAccessRequestsCardMenuAnchor({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: <Widget>[
        MenuItemButton(
          onPressed: () {},
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/delete.svg',
                colorFilter: const ColorFilter.mode(
                  Color.fromARGB(255, 255, 57, 43),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              const Text('Withdraw'),
            ],
          ),
        ),
        MenuItemButton(
          onPressed: () {},
          child: const Row(
            children: [
              Icon(
                Icons.block,
                color: Colors.green,
              ),
              SizedBox(
                width: 12,
              ),
              Text('Remind'),
            ],
          ),
        ),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        );
      },
    );
  }
}
