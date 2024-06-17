import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_letter_avatar.dart';

class SentAccessRequestsCard extends StatelessWidget {
  const SentAccessRequestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).brightness == Brightness.dark
            ? makeColorLighter(Theme.of(context).primaryColor, 20)
            : const Color.fromARGB(255, 176, 208, 235),
        border: Border.all(width: 1),
      ),
      height: 70,
      child: const Row(
        children: [
          SizedBox(
            width: 29,
          ),
          ContactLetterAvatar(contactName: 'Bolexy'),
          SizedBox(
            width: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'To Bolexyro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Click to view'),
            ],
          ),
          Spacer(),
          Text(
            'Status: Pending',
            style: TextStyle(color: Colors.orange),
          ),
          SizedBox(
            width: 10,
          ),
          SentAccessRequestsCardMenuAnchor(),
        ],
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
              const Text('Delete'),
            ],
          ),
        ),
        MenuItemButton(
          onPressed: () {},
          child: const Row(
            children: [
              Icon(
                Icons.block,
                color: Color.fromARGB(255, 255, 57, 43),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Block'),
            ],
          ),
        ),
        const MenuItemButton(
          child: Row(
            children: [
              Icon(Icons.qr_code),
              SizedBox(
                width: 12,
              ),
              Text('QR Code'),
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
