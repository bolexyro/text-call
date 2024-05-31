import 'dart:convert';

class ComplexMessage {
  ComplexMessage({required this.complexMessageJsonString});

  final String complexMessageJsonString;

  Map<int, Map<String, dynamic>> get bolexyroJson =>
      convertStringKeysToInt(jsonDecode(complexMessageJsonString));
}

Map<int, Map<String, dynamic>> convertStringKeysToInt(Map<String, dynamic> originalMap) {
  return originalMap.map((key, value) {
    int intKey = int.parse(key);  // Convert the key to an integer
    return MapEntry(intKey, Map<String, dynamic>.from(value));
  });
}
