import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/utils/utils.dart';

const String contactsTableName = 'contacts';

class ContactsNotifier extends StateNotifier<List<Contact>> {
  ContactsNotifier() : super([]);

  Future<void> loadContacts() async {
    final db = await getDatabase();
    final data = await db.query(contactsTableName);
    if (data.isNotEmpty) {
      return;
    }
    final contactsList = data
        .map(
          (row) => Contact(
            name: row['name'] as String,
            phoneNumber: row['phoneNumber'] as String,
            imagePath: row['imagePath'] as String?,
          ),
        )
        .toList();
    state = contactsList;
  }

  Future<void> addContact(Contact newContact) async {
    final db = await getDatabase();

    final data = await db.query(
      contactsTableName,
      where: 'phoneNumber = ?',
      whereArgs: [newContact.phoneNumber],
    );

    if (data.isNotEmpty) {
      return;
    }

    db.insert(
      contactsTableName,
      {
        'phoneNumber': newContact.phoneNumber,
        'name': newContact.name,
        'imagePath': newContact.imagePath,
      },
    );
    state = [...state, newContact];
  }

  Future<void> updateContact(
      {required Contact oldContact, required Contact newContact}) async {
    final db = await getDatabase();
    db.update(
      contactsTableName,
      {
        'phoneNumber': newContact.phoneNumber,
        'name': newContact.name,
        'imagePath': newContact.imagePath
      },
      where: 'phoneNumber = ?',
      whereArgs: [oldContact.phoneNumber],
    );

    final List<Contact> newState = List.from(state)
      ..removeWhere((contact) => contact.phoneNumber == oldContact.phoneNumber);
    newState.add(newContact);
    state = newState;
  }

  void deleteContact(String phoneNumber) async {
    final db = await getDatabase();
    await db.delete(contactsTableName,
        where: 'phoneNumber = ?', whereArgs: [phoneNumber]);
    state = List.from(state)
      ..removeWhere((contact) => contact.phoneNumber == phoneNumber);
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, List<Contact>>(
  (ref) => ContactsNotifier(),
);
