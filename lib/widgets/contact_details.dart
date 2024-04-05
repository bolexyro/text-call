import 'package:flutter/material.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/widgets/contact_avatar_circle.dart';
import 'package:text_call/widgets/message_writer.dart';

class ContactDetails extends StatelessWidget {
  const ContactDetails({
    super.key,
    this.contact,
  });

  final Contact? contact;

  final _nonTransparentContainerheight = 180.0;
  final _circleAvatarRadius = 50.0;
  final _transparentAndNonTransparentWidth = 235.0;

  void _showModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) =>  const MessageWriter(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transparentContainerHeight =
        _circleAvatarRadius + _nonTransparentContainerheight;

    Widget activeContent = const Text(
      'Select a contact from the list on the left',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
    if (contact != null) {
      activeContent = Column(
        children: [
          Stack(
            children: [
              Container(
                height: transparentContainerHeight,
                width: _transparentAndNonTransparentWidth,
                color: Colors.transparent,
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: _nonTransparentContainerheight,
                  width: _transparentAndNonTransparentWidth,
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
                        contact!.name,
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
                            contact!.phoneNumber,
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
                            _showModalBottomSheet(context);
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
                left: (_transparentAndNonTransparentWidth / 2) -
                    _circleAvatarRadius,
                child: ContactAvatarCircle(
                  avatarRadius: _circleAvatarRadius,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 170,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
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
          SizedBox(
            width: 170,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
              ),
              child: const Text(
                'Storage locations',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: contact == null
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: activeContent,
          ),
        ],
      ),
    );
  }
}
