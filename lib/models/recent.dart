import 'package:flutter/material.dart';
import 'package:text_call/models/complex_message.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/regular_message.dart';

enum RecentCategory {
  outgoingAccepted(
    'Outgoing Accepted',
    Colors.green,
    iconPath: 'assets/icons/outgoing-call.svg',
  ),
  outgoingRejected(
    'Outgoing Rejected',
    Colors.red,
    iconPath: 'assets/icons/outgoing-call.svg',
  ),
  outgoingIgnored(
    'Outgoing Ignored',
    Color.fromARGB(255, 185, 112, 2),
    iconPath: 'assets/icons/outgoing-call.svg',
  ),
  outgoingUnreachable(
    'Outgoing Unreachable',
    Colors.grey,
    iconPath: 'assets/icons/outgoing-call.svg',
  ),
  incomingAccepted(
    'Incoming Accepted',
    Colors.green,
    iconPath: 'assets/icons/incoming-call.svg',
  ),
  incomingRejected(
    'Incoming Rejected',
    Colors.red,
    iconPath: 'assets/icons/incoming-call.svg',
  ),
  incomingIgnored(
    'Incoming Ignored',
    Color.fromARGB(255, 185, 112, 2),
    icon: Icon(Icons.phone_missed),
  );

  const RecentCategory(this.label, this.iconColor, {this.iconPath, this.icon});
  final String label;
  final Color iconColor;
  final String? iconPath;
  final Widget? icon;
}

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
