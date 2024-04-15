import 'package:flutter/material.dart';
import 'package:text_call/models/contact.dart';

enum RecentCategory {
  outgoingAccepted,
  outgoingRejected,
  outgoingMissed,
  incomingAccepted,
  incomingRejected,
  incomingMissed,
}

const Map<RecentCategory, Icon> recentCategoryIconMap = {
  RecentCategory.outgoingAccepted: Icon(
    Icons.call,
    color: Colors.green,
  ),
  RecentCategory.outgoingMissed: Icon(Icons.call_missed, color: Colors.green),
  RecentCategory.outgoingRejected: Icon(Icons.call_end, color: Colors.green),
  RecentCategory.incomingAccepted: Icon(Icons.call, color: Colors.blue),
  RecentCategory.incomingMissed: Icon(Icons.call_missed, color: Colors.blue),
  RecentCategory.incomingRejected: Icon(Icons.call_end, color: Colors.blue),
};

class Recent {
  Recent({
    required this.contact,
    required this.category,
    DateTime? callTime,
  }) : callTime = callTime ?? DateTime.now();

  final Contact contact;
  final RecentCategory category;
  final DateTime callTime;
}
