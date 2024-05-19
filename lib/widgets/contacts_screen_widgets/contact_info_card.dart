import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class ContactInfoCard extends ConsumerStatefulWidget {
  const ContactInfoCard({
    super.key,
    required this.contact,
    this.recent,
    required this.width,
  });

  final Contact contact;
  final Recent? recent;
  final double width;

  @override
  ConsumerState<ContactInfoCard> createState() =>
      _ContactCardWProfilePicStackState();
}

class _ContactCardWProfilePicStackState extends ConsumerState<ContactInfoCard> {
  final _nonTransparentContainerheight = 180.0;

  final _circleAvatarRadius = 40.0;

  late Contact _updatedContact;

  @override
  void initState() {
    _updatedContact = Contact(
      name: widget.contact.name,
      phoneNumber: widget.contact.phoneNumber,
      imagePath: widget.contact.imagePath,
      isMyContact: widget.contact.isMyContact,
    );
    super.initState();
  }

  void _updateContactDetails({required Contact newContact}) {
    if (newContact.name != _updatedContact.name ||
        newContact.phoneNumber != _updatedContact.phoneNumber) {
      setState(() {
        _updatedContact = Contact(
          name: newContact.name,
          phoneNumber: newContact.phoneNumber,
          imagePath: newContact.imagePath,
          isMyContact: _updatedContact.isMyContact,
        );
      });
    }
  }

  whichIconButton() {
    if (widget.recent != null) {
      return widget.recent!.recentIsAContact
          ? null
          : IconButton(
              onPressed: () async {
                showAddContactDialog(context,
                    phoneNumber: widget.recent!.contact.phoneNumber);
              },
              icon: const Icon(Icons.person_add),
            );
    } else {
      late final Contact? contact;
      return IconButton(
        onPressed: () async {
          if (_updatedContact.isMyContact) {
            contact = await showAddContactDialog(context,
                phoneNumber: _updatedContact.phoneNumber,
                contact: _updatedContact);
          } else {
            contact =
                await showAddContactDialog(context, contact: _updatedContact);
          }
          if (contact == null) {
            return;
          }
          _updateContactDetails(newContact: contact!);
        },
        icon: const Icon(Icons.edit),
      );
    }
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
              width: widget.width,
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
              left: (widget.width / 2) - _circleAvatarRadius,
              child: widget.recent != null
                  ? ContactAvatarCircle(
                      avatarRadius: _circleAvatarRadius,
                      imagePath: _updatedContact.imagePath,
                    )
                  : Hero(
                      tag: widget.contact.phoneNumber,
                      child: ContactAvatarCircle(
                        onCirclePressed: widget.contact.imagePath == null
                            ? () async {
                                final File? imageFile =
                                    await selectImage(context);
                                if (imageFile == null) {
                                  return;
                                }
                                final appDir = await syspaths
                                    .getApplicationDocumentsDirectory();
                                final filename = path.basename(imageFile.path);
                                await imageFile
                                    .copy('${appDir.path}/$filename');

                                setState(() {
                                  _updatedContact = Contact(
                                    name: _updatedContact.name,
                                    phoneNumber: _updatedContact.phoneNumber,
                                    imagePath: imageFile.path,
                                  );
                                });
                                ref
                                    .read(contactsProvider.notifier)
                                    .updateContact(
                                      oldContactPhoneNumber:
                                          _updatedContact.phoneNumber,
                                      newContact: _updatedContact,
                                    );
                              }
                            : null,
                        avatarRadius: _circleAvatarRadius,
                        imagePath: _updatedContact.imagePath,
                      ),
                    ),
            ),
            Positioned(
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: whichIconButton(),
              ),
            )
          ],
        ),
      ],
    );
  }
}
