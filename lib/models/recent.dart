enum RecentCategory {
  outgoingAccepted,
  outgoingRejected,
  outgoingMissed,
  incomingAccepted,
  incomingRejected,
  incomingMissed,
}

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
