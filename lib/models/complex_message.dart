import 'dart:convert';

class ComplexMessage {
  ComplexMessage({required this.complexMessageJsonString});

  final String complexMessageJsonString;

  Map<String, dynamic> get bolexyroJson =>
      jsonDecode(complexMessageJsonString);
}



