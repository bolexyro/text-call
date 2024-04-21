import 'dart:async';
import 'dart:convert';

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

class RecentsNotifier extends StateNotifier<List<Recent>> {
  RecentsNotifier() : super([]);

  Future<void> loadRecents() async {
    final db = await getDatabase();
    final data = await db.query('recents');
    final recentsList = data
        .map(
          (row) => Recent(
            message: Message(
              message: row['message'] as String,
              backgroundColor: deJsonifyColor(
                json.decode(row['backgroundColorJson'] as String),
              ),
            ),
            contact: Contact(
                name: row['name'] as String,
                phoneNumber: row['phoneNumber'] as String),
            category: _getCategoryEnumFromText(
              recentCategoryText: row['categoryName'] as String,
            )!,
            callTime: DateTime.parse(row['callTime'] as String),
          ),
        )
        .toList();
    state = recentsList;
  }

  void addRecent(Recent newRecent) async {
    final db = await getDatabase();
    db.insert(
      'recents',
      {
        'backgroundColorJson':
            json.encode(jsonifyColor(newRecent.message.backgroundColor))
                .toString(),
        'message': newRecent.message.message,
        'callTime': newRecent.callTime.toString(),
        'phoneNumber': newRecent.contact.phoneNumber,
        'name': newRecent.contact.name,
        'categoryName': newRecent.category.name,
      },
    );
    state = [...state, newRecent];
  }

  Future<List<Recent>> getRecentForAContact(String phoneNumber) async {
    final db = await getDatabase();
    final data = await db
        .query('recents', where: 'phoneNumber = ?', whereArgs: [phoneNumber]);
    final recentsList = data
        .map(
          (row) => Recent(
            message: Message(
              message: row['message'] as String,
              backgroundColor: deJsonifyColor(
                json.decode(row['backgroundColorJson'] as String),
              ),
            ),
            contact:
                Contact(name: row['name'] as String, phoneNumber: phoneNumber),
            category: _getCategoryEnumFromText(
              recentCategoryText: row['categoryName'] as String,
            )!,
            callTime: DateTime.parse(row['callTime'] as String),
          ),
        )
        .toList();

    return recentsList;
  }
}

final recentsProvider = StateNotifierProvider<RecentsNotifier, List<Recent>>(
  (ref) => RecentsNotifier(),
);
