import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/utils/utils.dart';

class ContactsNotifier extends StateNotifier<List<Contact>> {
  ContactsNotifier() : super([]);

  Future<void> loadContacts() async {
    final db = await getDatabase();
    final data = await db.query('contacts');
    final contactsList = data
        .map((row) => Contact(
            name: row['name'] as String,
            phoneNumber: row['phoneNumber'] as String))
        .toList();
    state = contactsList;
  }

  Future<Contact?> readAContact(String phoneNumber) async {
    final db = await getDatabase();
    final data = await db
        .query('contacts', where: 'phoneNumber = ?', whereArgs: [phoneNumber]);

    if (data.isEmpty) {
      return null;
    }
    return Contact(name: data[0]['name'] as String, phoneNumber: phoneNumber);
  }

  void addContact(Contact newContact) async {
    final db = await getDatabase();
    db.insert(
      'contacts',
      {'phoneNumber': newContact.phoneNumber, 'name': newContact.name},
    );
    state = [...state, newContact];
  }

  void deleteContact(String phoneNumber) async {
    final db = await getDatabase();
    await db
        .delete('contacts', where: 'phoneNumber = ?', whereArgs: [phoneNumber]);
    state = List.from(state)
      ..removeWhere((contact) => contact.phoneNumber == phoneNumber);
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, List<Contact>>(
  (ref) => ContactsNotifier(),
);
