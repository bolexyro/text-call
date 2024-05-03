import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';

class ContactCardWProfilePicStack extends StatefulWidget {
  const ContactCardWProfilePicStack({
    super.key,
    required this.contact,
    required this.transparentAndNonTransparentWidth,
  });

  final Contact contact;
  final double transparentAndNonTransparentWidth;

  @override
  State<ContactCardWProfilePicStack> createState() =>
      _ContactCardWProfilePicStackState();
}

class _ContactCardWProfilePicStackState
    extends State<ContactCardWProfilePicStack> {
  final _nonTransparentContainerheight = 180.0;

  final _circleAvatarRadius = 40.0;

  late Contact _updatedContact;

  @override
  void initState() {
    _updatedContact = Contact(
        name: widget.contact.name,
        phoneNumber: widget.contact.phoneNumber,
        imagePath: widget.contact.imagePath);
    super.initState();
  }

  void _updateContactDetails({required Contact newContact}) {
    // if (newContact.name != contactName || newContact.phoneNumber != contactPhoneNumber) {
    setState(() {
      _updatedContact = newContact;
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Column(
      children: [
        SizedBox(
          height: _circleAvatarRadius,
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: _nonTransparentContainerheight,
              width: widget.transparentAndNonTransparentWidth,
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
                      _updatedContact.name,
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
                          _updatedContact.localPhoneNumber,
                          overflow: TextOverflow.ellipsis,
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
                              calleeName: widget.contact.name,
                              calleePhoneNumber: widget.contact.phoneNumber);
                        },
                        icon: SvgPicture.asset(
                          'assets/icons/message-ring.svg',
                          height: 30,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: -_circleAvatarRadius,
              left: (widget.transparentAndNonTransparentWidth / 2) -
                  _circleAvatarRadius,
              child: ContactAvatarCircle(
                purpose: widget.contact.imagePath == null
                    ? Purpose.selectingImage
                    : Purpose.displayingImage,
                avatarRadius: _circleAvatarRadius,
                imagePath: widget.contact.imagePath,
              ),
            ),
            Positioned(
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: IconButton(
                  onPressed: () async {
                    final contact = await showAddContactDialog(context,
                        contact: _updatedContact);
                    if (contact == null) {
                      return;
                    }
                    _updateContactDetails(newContact: contact);
                  },
                  icon: const Icon(Icons.edit),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
