import 'dart:async';
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
    state = [...state, phoneNumber];
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(blockedContactsListName, state);
  }

  void unblockContact(WidgetRef ref, String phoneNumber) async {
    state = state
        .where((blockedPhoneNumber) => blockedPhoneNumber != phoneNumber)
        .toList();
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(blockedContactsListName, state);
  }
}

final blockedContactsProvider =
    StateNotifierProvider<BlockedContactsNotifier, List<String>>(
  (ref) => BlockedContactsNotifier(),
);
