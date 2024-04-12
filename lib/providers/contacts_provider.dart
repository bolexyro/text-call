import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:text_call/models/contact.dart';

Future<sql.Database> _getDatabase() async {
  final databasesPath = await sql.getDatabasesPath();

  final db = await sql.openDatabase(
    path.join(databasesPath, 'contacts.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE contacts (phoneNumber TEXT PRIMARY KEY, name TEXT)');
      await db.execute('CREATE TABLE recents (callDate TEXT PRIMARY KEY, phoneNumber TEXT, name TEXT, categoryName TEXT)');
    },
  );
  return db;
}

class ContactsNotifier extends StateNotifier<List<Contact>> {
  ContactsNotifier() : super([]);

  Future<void> loadContacts() async {
    final db = await _getDatabase();
    final data = await db.query('contacts');
    final contactsList = data
        .map((row) => Contact(
            name: row['name'].toString(),
            phoneNumber: row['phoneNumber'].toString()))
        .toList();
    state = contactsList;
  }

  Future<Contact?> readAContact(String phoneNumber) async {
    final db = await _getDatabase();
    final data = await db
        .query('contacts', where: 'phoneNumber = ?', whereArgs: [phoneNumber]);

    if (data.isEmpty) {
      return null;
    }
    return Contact(name: data[0]['name'] as String, phoneNumber: phoneNumber);
  }

  void addContact(Contact newContact) async {
    final db = await _getDatabase();
    db.insert(
      'contacts',
      {'phoneNumber': newContact.phoneNumber, 'name': newContact.name},
    );
    state = [...state, newContact];
  }

  void deleteContact(String phoneNumber) async {
    final db = await _getDatabase();
    await db
        .delete('contacts', where: 'phoneNumber = ?', whereArgs: [phoneNumber]);
    state = List.from(state)
      ..removeWhere((contact) => contact.phoneNumber == phoneNumber);
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, List<Contact>>(
  (ref) => ContactsNotifier(),
);
