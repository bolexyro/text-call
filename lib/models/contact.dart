class Contact {
  const Contact({
    required this.name,
    required this.phoneNumber,
  });

  final String name;
  final String phoneNumber;

  String get localPhoneNumber => '0${phoneNumber.substring(4)}';
}
