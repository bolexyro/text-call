import 'package:flutter/material.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';

class ContactDetailsScreen extends StatelessWidget {
  const ContactDetailsScreen({
    super.key,
    required this.contact,
  });

  final Contact contact;

  final _nonTransparentContainerheight = 180.0;
  final _circleAvatarRadius = 50.0;
  final _stackPadding = const EdgeInsets.symmetric(horizontal: 10);

  @override
  Widget build(BuildContext context) {
    final transparentAndNonTransparentWidth =
        MediaQuery.sizeOf(context).width - _stackPadding.horizontal;
    final transparentContainerHeight =
        _circleAvatarRadius + _nonTransparentContainerheight;

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              Padding(
                padding: _stackPadding,
                child: Stack(
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
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: _circleAvatarRadius,
                            ),
                            Text(
                              contact.name,
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
                                  formatPhoneNumber(
                                      phoneNumberWCountryCode:
                                          contact.phoneNumber),
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
                                color: Colors.blue[500],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  showMessageWriterModalSheet(
                                    context: context,
                                    calleePhoneNumber: contact.phoneNumber,
                                    calleeName: contact.name,
                                  );
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
                    Positioned(
                      left: (transparentAndNonTransparentWidth / 2) -
                          _circleAvatarRadius,
                      child: ContactAvatarCircle(
                        avatarRadius: _circleAvatarRadius,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 170,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text(
                    'History',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
