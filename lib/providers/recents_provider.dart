import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/message.dart';
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

Future<List> getContactAndExistsStatus({required String phoneNumber, required Database db,}) async {
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
            message: Message(
              message: row['message'] as String,
              backgroundColor: Color.fromARGB(
                row['backgroundColorAlpha'] as int,
                row['backgroundColorRed'] as int,
                row['backgroundColorGreen'] as int,
                row['backgroundColorBlue'] as int,
              ),
            ),
            contact: (await getContactAndExistsStatus(db: db,
                phoneNumber: row['phoneNumber'] as String))[0],
            category: _getCategoryEnumFromText(
              recentCategoryText: row['categoryName'] as String,
            )!,
            recentIsAContact: (await getContactAndExistsStatus(db: db,
                phoneNumber: row['phoneNumber'] as String))[1],
            callTime: DateTime.parse(row['callTime'] as String),
          ),
        )
        .toList();
    final resolvedRecents = await Future.wait(recentsList);
    state = resolvedRecents;
  }

  void addRecent(Recent newRecent) async {
    final db = await getDatabase();
    db.insert(
      'recents',
      {
        'id': newRecent.id,
        'backgroundColorAlpha': newRecent.message.backgroundColor.alpha,
        'backgroundColorRed': newRecent.message.backgroundColor.red,
        'backgroundColorGreen': newRecent.message.backgroundColor.green,
        'backgroundColorBlue': newRecent.message.backgroundColor.blue,
        'message': newRecent.message.message,
        'callTime': newRecent.callTime.toString(),
        'phoneNumber': newRecent.contact.phoneNumber,
        'categoryName': newRecent.category.name,
      },
    );

    final contactAndContactExistsStatus = await getContactAndExistsStatus(db: db,
        phoneNumber: newRecent.contact.phoneNumber);
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
