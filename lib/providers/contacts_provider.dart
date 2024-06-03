import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/utils/utils.dart';

const String contactsTableName = 'contacts';

class ContactsNotifier extends StateNotifier<List<Contact>> {
  ContactsNotifier() : super([]);

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String myPhoneNumber = prefs.getString('myPhoneNumber')!;
    final db = await getDatabase();
    final data = await db.query(contactsTableName);
    final contactsList = data
        .map(
          (row) => Contact(
            name: row['name'] as String,
            phoneNumber: row['phoneNumber'] as String,
            imagePath: row['imagePath'] as String?,
            isMyContact:
                row['phoneNumber'] as String == myPhoneNumber ? true : false,
          ),
        )
        .toList();
    state = contactsList;
  }

  Future<void> addContact(Contact newContact) async {
    final db = await getDatabase();

    db.insert(
      contactsTableName,
      {
        'phoneNumber': newContact.phoneNumber,
        'name': newContact.name,
        'imagePath': newContact.imagePath,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    state = [...state, newContact];
  }

  Future<void> updateContact(
      {required WidgetRef ref,
      required String oldContactPhoneNumber,
      required Contact newContact}) async {
    final db = await getDatabase();
    await db.update(
      contactsTableName,
      {
        'phoneNumber': newContact.phoneNumber,
        'name': newContact.name,
        'imagePath': newContact.imagePath
      },
      where: 'phoneNumber = ?',
      whereArgs: [oldContactPhoneNumber],
    );

    await db.update(
      'recents',
      {'phoneNumber': newContact.phoneNumber},
      where: 'phoneNumber = ?',
      whereArgs: [oldContactPhoneNumber],
    );

    final List<Contact> newState = List.from(state)
      ..removeWhere((contact) => contact.phoneNumber == oldContactPhoneNumber);
    newState.add(newContact);
    state = newState;
    await ref
        .read(recentsProvider.notifier)
        .updateRecentContact(oldContactPhoneNumber, newContact);
  }

  void deleteContact(String phoneNumber) async {
    final db = await getDatabase();
    await db.delete(
      contactsTableName,
      where: 'phoneNumber = ?',
      whereArgs: [phoneNumber],
    );

    await db.delete(
      'recents',
      where: 'phoneNumber = ?',
      whereArgs: [phoneNumber],
    );
    state = List.from(state)
      ..removeWhere(
        (contact) => contact.phoneNumber == phoneNumber,
      );
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, List<Contact>>(
  (ref) => ContactsNotifier(),
);
