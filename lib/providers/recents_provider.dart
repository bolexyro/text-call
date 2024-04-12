import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:text_call/models/recent.dart';

RecentCategory? _getCategoryEnumFromText({required String recentCategoryText}) {
  for (final recentCategoryEnum in RecentCategory.values) {
    if (recentCategoryEnum.name == recentCategoryText) {
      return recentCategoryEnum;
    }
  }
  // this will never be executed
  return null;
}

Future<sql.Database> _getDatabase() async {
  final databasesPath = await sql.getDatabasesPath();

  final db = await sql.openDatabase(
    path.join(databasesPath, 'contacts.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE contacts (phoneNumber TEXT PRIMARY KEY, name TEXT)');
      await db.execute(
          'CREATE TABLE recents (callTime TEXT PRIMARY KEY, phoneNumber TEXT, name TEXT, categoryName TEXT)');
    },
  );
  return db;
}

class RecentsNotifier extends StateNotifier<List> {
  RecentsNotifier() : super([]);

  Future<void> loadContacts() async {
    final db = await _getDatabase();
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
    final db = await _getDatabase();
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

}

final recentsProvider =
    StateNotifierProvider<RecentsNotifier, List>((ref) => RecentsNotifier());
