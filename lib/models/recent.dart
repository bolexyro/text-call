import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/message.dart';
import 'package:text_call/utils/constants.dart';

enum RecentCategory {
  outgoingAccepted,
  outgoingRejected,
  outgoingUnanswered,
  incomingAccepted,
  incomingRejected,
  incomingMissed,
}

Map<RecentCategory, Widget> recentCategoryIconMap = {
  RecentCategory.outgoingAccepted: SvgPicture.asset(
    'assets/icons/outgoing-call.svg',
    height: kIconHeight,
    colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
  ),
  RecentCategory.outgoingUnanswered: SvgPicture.asset(
    'assets/icons/outgoing-call.svg',
    height: kIconHeight,
    colorFilter: const ColorFilter.mode(
        Color.fromARGB(255, 185, 112, 2), BlendMode.srcIn),
  ),
  RecentCategory.outgoingRejected: SvgPicture.asset(
    'assets/icons/outgoing-call.svg',
    height: kIconHeight,
    colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
  ),
  RecentCategory.incomingAccepted: SvgPicture.asset(
    'assets/icons/incoming-call.svg',
    height: kIconHeight,
    colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
  ),

  RecentCategory.incomingMissed:
      const Icon(Icons.phone_missed, color: Colors.blue),

  RecentCategory.incomingRejected: SvgPicture.asset(
    'assets/icons/incoming-call.svg',
    height: kIconHeight,
    colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
  ),
};

const Map<RecentCategory, String> recntCategoryStringMap = {
  RecentCategory.outgoingAccepted: 'Outgoing Accepted',
  RecentCategory.outgoingUnanswered: 'Outgoing Unanswered',
  RecentCategory.outgoingRejected: 'Outgoing Rejected',
  RecentCategory.incomingAccepted: 'Incoming Accepted',
  RecentCategory.incomingMissed: 'Incoming Missed',
  RecentCategory.incomingRejected: 'Incoming Rejected',
};

class Recent {
  Recent({
    required this.contact,
    required this.category,
    required this.message,
    DateTime? callTime,
    this.recentIsAContact = false,
    required this.id,
  }) : callTime = callTime ?? DateTime.now();

  Recent.fromRecent({
    required Recent recent,
    required this.recentIsAContact,
    required String contactName,
    required String? contactImagePath,
  })  : contact = Contact(
            name: contactName,
            phoneNumber: recent.contact.phoneNumber,
            imagePath: null),
        category = recent.category,
        callTime = recent.callTime,
        message = recent.message,
        id = recent.id;

  Recent.withoutContactObject({
    required this.category,
    required this.message,
    required this.id,
    DateTime? callTime,
    required String phoneNumber,
    this.recentIsAContact = false,
  })  : callTime = callTime ?? DateTime.now(),
        contact = Contact(
          name: 'name',
          phoneNumber: phoneNumber,
          imagePath: null,
        );

  final Contact contact;
  final RecentCategory category;
  final DateTime callTime;
  final Message message;
  final bool recentIsAContact;
  // this id would be the same on the caller and callee's phones. It is used to identify the recent message
  // we are requesting access for
  final String id;
}
