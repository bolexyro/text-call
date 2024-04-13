import 'package:flutter/material.dart';

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
    required this.name,
    required this.phoneNumber,
    required this.category,
    DateTime? callTime,
  }) : callTime = callTime ?? DateTime.now();

  final String name;
  final String phoneNumber;
  final RecentCategory category;
  final DateTime callTime;
}
