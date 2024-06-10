import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:text_call/models/complex_message.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/regular_message.dart';
import 'package:text_call/utils/constants.dart';

enum RecentCategory {
  outgoingAccepted,
  outgoingRejected,
  outgoingIgnored,
  outgoingUnreachable,
  incomingAccepted,
  incomingRejected,
  incomingIgnored,
}

Map<RecentCategory, Widget> recentCategoryIconMap = {
  RecentCategory.outgoingAccepted: SvgPicture.asset(
    'assets/icons/outgoing-call.svg',
    height: kIconHeight,
    colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
  ),
  RecentCategory.outgoingUnreachable: SvgPicture.asset(
    'assets/icons/outgoing-call.svg',
    height: kIconHeight,
    colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
  ),
  RecentCategory.outgoingIgnored: SvgPicture.asset(
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
  RecentCategory.incomingIgnored: const Icon(
    Icons.phone_missed,
    color: Color.fromARGB(255, 185, 112, 2),
  ),
  RecentCategory.incomingRejected: SvgPicture.asset(
    'assets/icons/incoming-call.svg',
    height: kIconHeight,
    colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
  ),
};

const Map<RecentCategory, String> recntCategoryStringMap = {
  RecentCategory.outgoingAccepted: 'Outgoing Accepted',
  RecentCategory.outgoingRejected: 'Outgoing Rejected',
  RecentCategory.outgoingIgnored: 'Outgoing Ignored',
  RecentCategory.incomingIgnored: 'Incoming Ignored',
  RecentCategory.outgoingUnreachable: 'Outgoing unreachable',
  RecentCategory.incomingAccepted: 'Incoming Accepted',
  RecentCategory.incomingRejected: 'Incoming Rejected',
};

class Recent {
  Recent({
    required this.contact,
    required this.category,
    required this.regularMessage,
    required this.complexMessage,
    DateTime? callTime,
    this.recentIsAContact = false,
    this.canBeViewed = true,
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
        canBeViewed = recent.canBeViewed,
        callTime = recent.callTime,
        regularMessage = recent.regularMessage,
        complexMessage = recent.complexMessage,
        id = recent.id;

  Recent.withoutContactObject({
    required this.category,
    required this.regularMessage,
    required this.complexMessage,
    required this.id,
    DateTime? callTime,
    required String phoneNumber,
    this.recentIsAContact = false,
    this.canBeViewed = true,
  })  : callTime = callTime ?? DateTime.now(),
        contact = Contact(
          name: '0${phoneNumber.substring(4)}',
          phoneNumber: phoneNumber,
          imagePath: null,
        );

  final Contact contact;
  final RecentCategory category;
  final DateTime callTime;
  // this id would be the same on the caller and callee's phones. It is used to identify the recent message
  // we are requesting access for
  final String id;
  final bool recentIsAContact;

  final RegularMessage? regularMessage;
  final ComplexMessage? complexMessage;
  final bool canBeViewed;
}
