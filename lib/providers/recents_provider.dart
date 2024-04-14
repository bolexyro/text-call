import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class RecentsNotifier extends StateNotifier<List> {
  RecentsNotifier() : super([]);

  Future<void> loadRecents() async {
    final db = await getDatabase();
    final data = await db.query('recents');
    final recentsList = data
        .map(
          (row) => Recent(
            name: row['name'] as String,
            phoneNumber: row['phoneNumber'] as String,
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
        'callTime': newRecent.callTime.toString(),
        'phoneNumber': newRecent.phoneNumber,
        'name': newRecent.name,
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
            name: row['name'] as String,
            phoneNumber: row['phoneNumber'] as String,
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

final recentsProvider =
    StateNotifierProvider<RecentsNotifier, List>((ref) => RecentsNotifier());
