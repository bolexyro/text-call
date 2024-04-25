import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

Future<Contact> getContactName({required String phoneNumber}) async {
  final db = await getDatabase();
  final data = await db
      .query('contacts', where: 'phoneNumber = ?', whereArgs: [phoneNumber]);
  return Contact(
      name: data.isEmpty ? 'Unknown' : data[0]['name'] as String,
      phoneNumber: phoneNumber);
}

class RecentsNotifier extends StateNotifier<List<Recent>> {
  RecentsNotifier() : super([]);

  Future<void> loadRecents() async {
    final db = await getDatabase();
    final data = await db.query('recents');
    final recentsList = data
        .map(
          (row) async => Recent(
            message: Message(
              message: row['message'] as String,
              backgroundColor: Color.fromARGB(
                row['backgroundColorAlpha'] as int,
                row['backgroundColorRed'] as int,
                row['backgroundColorGreen'] as int,
                row['backgroundColorBlue'] as int,
              ),
            ),
            contact:
                await getContactName(phoneNumber: row['phoneNumber'] as String),
            category: _getCategoryEnumFromText(
              recentCategoryText: row['categoryName'] as String,
            )!,
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

    if ((await getContactName(phoneNumber: newRecent.contact.phoneNumber))
            .name ==
        'Unknown') {
      newRecent = Recent.fromRecent(recent: newRecent, contactName: 'Unkown');
    }
    state = [...state, newRecent];
  }
}

final recentsProvider = StateNotifierProvider<RecentsNotifier, List<Recent>>(
  (ref) => RecentsNotifier(),
);
