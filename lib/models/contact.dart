class Contact {
  const Contact({
    required this.name,
    required this.phoneNumber,
    required this.imagePath,
  });

  final String name;
  final String phoneNumber;
  final String? imagePath;

  String get localPhoneNumber => '0${phoneNumber.substring(4)}';
}
