class Contact {
  const Contact({
    required this.name,
    required this.phoneNumber,
    this.email,

  });

  final String name;
  final String phoneNumber;
  final String? email;
}
