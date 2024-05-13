class Contact {
  const Contact({
    required this.name,
    required this.phoneNumber,
    required this.imagePath,
    this.isMyContact = false,
  });

  final String name;
  final String phoneNumber;
  final String? imagePath;
  final bool isMyContact;

  String get localPhoneNumber => '0${phoneNumber.substring(4)}';

}
