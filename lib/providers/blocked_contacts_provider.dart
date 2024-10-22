import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String blockedContactsListName = 'blockedPhoneNumbers';

class BlockedContactsNotifier extends StateNotifier<List<String>> {
  BlockedContactsNotifier() : super([]);

  Future<void> loadBlockedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(blockedContactsListName) ?? [];
  }

  Future<void> addNewBlockedContact(String phoneNumber) async {
    state = [
      ...state,
      jsonEncode({'phoneNumber': phoneNumber, 'blockMessage': null})
    ];
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(blockedContactsListName, state);
  }

  void unblockContact(WidgetRef ref, String phoneNumber) async {
    state = state
        .where((eachJsonString) =>
            jsonDecode(eachJsonString)['phoneNumber'] != phoneNumber)
        .toList();
    final prefs = await SharedPreferences.getInstance();

    prefs.setStringList(blockedContactsListName, state);
  }

  Future<void> updateContactBlockMessage(
      String phoneNumber, String blockMessage) async {
    state = state.map((eachJsonString) {
      final eachJsonMap = jsonDecode(eachJsonString) as Map<String, dynamic>;
      if (eachJsonMap['phoneNumber'] == phoneNumber) {
        eachJsonMap['blockMessage'] = blockMessage;
      }

      return jsonEncode(eachJsonMap);
    }).toList();
    final prefs = await SharedPreferences.getInstance();

    prefs.setStringList(blockedContactsListName, state);
  }
}

final blockedContactsProvider =
    StateNotifierProvider<BlockedContactsNotifier, List<String>>(
  (ref) => BlockedContactsNotifier(),
);
