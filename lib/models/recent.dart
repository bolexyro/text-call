import 'package:flutter/material.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/message.dart';

enum RecentCategory {
  outgoingAccepted,
  outgoingRejected,
  outgoingUnanswered,
  incomingAccepted,
  incomingRejected,
  incomingMissed,
}

const Map<RecentCategory, Icon> recentCategoryIconMap = {
  RecentCategory.outgoingAccepted: Icon(
    Icons.call,
    color: Colors.green,
  ),
  RecentCategory.outgoingUnanswered:
      Icon(Icons.call_missed, color: Colors.green),
  RecentCategory.outgoingRejected: Icon(Icons.call_end, color: Colors.green),
  RecentCategory.incomingAccepted: Icon(Icons.call, color: Colors.blue),
  RecentCategory.incomingMissed: Icon(Icons.call_missed, color: Colors.blue),
  RecentCategory.incomingRejected: Icon(Icons.call_end, color: Colors.blue),
};

const Map<RecentCategory, String> recntCategoryString = {
  RecentCategory.outgoingAccepted: 'Incoming Accepted',
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
  }) : callTime = callTime ?? DateTime.now();

  Recent.fromRecent({required Recent recent, required String contactName})
      : contact =
            Contact(name: contactName, phoneNumber: recent.contact.phoneNumber),
        category = recent.category,
        callTime = recent.callTime,
        message = recent.message;

  final Contact contact;
  final RecentCategory category;
  final DateTime callTime;
  final Message message;
}
