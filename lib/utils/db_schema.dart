import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

Future<sql.Database> getDatabase() async {
  final databasesPath = await sql.getDatabasesPath();

  final db = await sql.openDatabase(
    path.join(databasesPath, 'contacts.db'),
    version: 2,
    onCreate: (db, newVersion) async {
      for (int version = 0; version < newVersion; version++) {
        _performDbOperationsVersionWise(db, version + 1);
      }
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      for (int version = oldVersion; version < newVersion; version++) {
        _performDbOperationsVersionWise(db, version + 1);
      }
    },
  );
  return db;
}

Future<void> _performDbOperationsVersionWise(
    sql.Database db, int version) async {
  switch (version) {
    case 1:
      await _databaseVersion1(db);
      break;
    case 2:
      await _databaseVersion2(db);
      break;
  }
}

Future<void> _databaseVersion1(sql.Database db) async {
  await db.execute(
      'CREATE TABLE contacts (phoneNumber TEXT PRIMARY KEY, name TEXT, imagePath TEXT)');

  // if you make id primary key, it makes sense but the only thing different between it and making calltime primary key
  // is that for id as primary key, when you call yourself, both the incoming and outgoing calls will have the same recentid
  // so you can't insert both into the db, it would ignore the second insert.
  // but with datetime, you can insert  both since the time you called ain't the same time you picked up.
  // but the pick up time would be earlier than the outgoing since the user has t o first pick up or decline
  // before we know what category of recents to insert in the db.
  await db.execute(
      'CREATE TABLE recents ( id TEXT, callTime TEXT PRIMARY KEY, phoneNumber TEXT, categoryName TEXT, messageJson TEXT, messageType TEXT, canBeViewed INTEGER)');
}

Future<void> _databaseVersion2(sql.Database db) async {
  await db.execute(
      'CREATE TABLE access_requests ( recentId TEXT PRIMARY KEY, time TEXT, isSent INTEGER, status TEXT)');
}
