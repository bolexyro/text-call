import 'package:flutter/material.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_letter_avatar.dart';

class ReceivedAccessRequestCard extends StatelessWidget {
  const ReceivedAccessRequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).brightness == Brightness.dark
            ? makeColorLighter(Theme.of(context).primaryColor, 20)
            : const Color.fromARGB(255, 176, 208, 235),
        border: Border.all(width: 1),
      ),
      height: 60,
      child: Row(
        children: [
          const SizedBox(
            width: 29,
          ),
          const ContactLetterAvatar(contactName: 'Bolexy'),
          const SizedBox(
            width: 20,
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'From Bolexyro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Click to view'),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
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
            onTap: () {},
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
    );
  }
}
