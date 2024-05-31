import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_call/models/complex_message.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/regular_message.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/utils/utils.dart';

RecentCategory? _getCategoryEnumFromText({required String recentCategoryText}) {
  for (final recentCategoryEnum in RecentCategory.values) {
    if (recentCategoryEnum.name == recentCategoryText) {
      return recentCategoryEnum;
    }
  }
  // this will never be executed
  return null;
}

Future<List> getContactAndExistsStatus({
  required String phoneNumber,
  required Database db,
}) async {
  final data = await db
      .query('contacts', where: 'phoneNumber = ?', whereArgs: [phoneNumber]);
  final contactExists = data.isNotEmpty;

  return [
    Contact(
      name: contactExists
          ? data[0]['name'] as String
          : '0${phoneNumber.substring(4)}',
      phoneNumber: phoneNumber,
      imagePath: contactExists ? data[0]['imagePath'] as String? : null,
    ),
    contactExists
  ];
}

class RecentsNotifier extends StateNotifier<List<Recent>> {
  RecentsNotifier() : super([]);

  Future<void> loadRecents() async {
    final db = await getDatabase();
    final data = await db.query('recents');
    final recentsList = data
        .map(
          (row) async => Recent(
            id: row['id'] as String,
            regularMessage: row['messageType'] == 'regular'
                ? RegularMessage.fromJsonString(
                    row['messageJson'] as String,
                  )
                : null,
            complexMessage: row['messageType'] == 'complex'
                ? ComplexMessage(
                    complexMessageJsonString: row['messageJson'] as String)
                : null,
            contact: (await getContactAndExistsStatus(
                db: db, phoneNumber: row['phoneNumber'] as String))[0],
            category: _getCategoryEnumFromText(
              recentCategoryText: row['categoryName'] as String,
            )!,
            recentIsAContact: (await getContactAndExistsStatus(
                db: db, phoneNumber: row['phoneNumber'] as String))[1],
            callTime: DateTime.parse(row['callTime'] as String),
          ),
        )
        .toList();
    final resolvedRecents = await Future.wait(recentsList);
    state = resolvedRecents;
  }

  Future<void> updateRecentContact(
      String oldPhoneNumber, Contact newContact) async {
    final List<Recent> updatedRecents = state.map(
      (recent) {
        if (recent.contact.phoneNumber == oldPhoneNumber) {
          return Recent(
            contact: Contact(
              name: newContact.name,
              phoneNumber: newContact.phoneNumber,
              imagePath: newContact.imagePath,
            ),
            category: recent.category,
            complexMessage: recent.complexMessage,
            regularMessage: recent.regularMessage,
            id: recent.id,
          );
        }
        return recent;
      },
    ).toList();

    state = updatedRecents;
  }

  void addRecent(Recent newRecent) async {
    final db = await getDatabase();
    addRecentToDb(newRecent, db);

    final contactAndContactExistsStatus = await getContactAndExistsStatus(
        db: db, phoneNumber: newRecent.contact.phoneNumber);
    newRecent = Recent.fromRecent(
      recent: newRecent,
      recentIsAContact: contactAndContactExistsStatus[1],
      contactName: (contactAndContactExistsStatus[0] as Contact).name,
      contactImagePath: (contactAndContactExistsStatus[0] as Contact).imagePath,
    );
    state = [...state, newRecent];
  }
}

final recentsProvider = StateNotifierProvider<RecentsNotifier, List<Recent>>(
  (ref) => RecentsNotifier(),
);
