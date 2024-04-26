import 'package:flutter/material.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';

class ContactCardWProfilePicStack extends StatelessWidget {
  const ContactCardWProfilePicStack({
    super.key,
    required this.contact,
    required this.transparentAndNonTransparentWidth,
  });

  final Contact contact;
  final double transparentAndNonTransparentWidth;

  final _nonTransparentContainerheight = 180.0;
  final _circleAvatarRadius = 40.0;

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    final transparentContainerHeight =
        _circleAvatarRadius + _nonTransparentContainerheight;

    return Stack(
      children: [
        Container(
          height: transparentContainerHeight,
          width: transparentAndNonTransparentWidth,
          color: Colors.transparent,
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: _nonTransparentContainerheight,
            width: transparentAndNonTransparentWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDarkTheme
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: _circleAvatarRadius,
                  ),
                  Text(
                    contact.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Mobile'),
                      const SizedBox(
                        width: 7,
                      ),
                      Text(
                        overflow: TextOverflow.ellipsis,
                        contact.localPhoneNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSecondary
                          : Colors.blue[500],
                    ),
                    child: IconButton(
                      onPressed: () {
                        showMessageWriterModalSheet(
                            context: context,
                            calleeName: contact.name,
                            calleePhoneNumber: contact.phoneNumber);
                      },
                      icon: const Icon(
                        Icons.message,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: (transparentAndNonTransparentWidth / 2) - _circleAvatarRadius,
          child: ContactAvatarCircle(
            avatarRadius: _circleAvatarRadius,
          ),
        )
      ],
    );
  }
}
