import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/recent.dart';

const String contactsTableName = 'contacts';
const String recentsTableName = 'recents';
const String accessRequestsTableName = 'access_requests';

Future<sql.Database> getDatabase() async {
  final databasesPath = await sql.getDatabasesPath();

  final db = await sql.openDatabase(
    path.join(databasesPath, 'contacts.db'),
    version: 1,
    onCreate: (db, version) async {
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
      await db.execute(
          'CREATE TABLE access_requests ( recentId TEXT PRIMARY KEY, time TEXT, isSent INTEGER, status TEXT)');
    },
  );
  return db;
}

Future<List> getContactAndExistsStatus({
  sql.Database? db,
  required String phoneNumber,
}) async {
  final data = await readContactsFromDb(db: db, wherePhoneNumber: phoneNumber);
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

Future<void> insertContactIntoDb({required Contact newContact}) async {
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
}

Future<List<Map<String, Object?>>> readContactsFromDb(
    {String? wherePhoneNumber, sql.Database? db}) async {
  db ??= await getDatabase();
  if (wherePhoneNumber != null) {
    return await db.query(contactsTableName,
        where: 'phoneNumber = ?', whereArgs: [wherePhoneNumber]);
  }
  return await db.query(contactsTableName);
}

Future<void> updateContactInDb(
    {required Contact newContact, required String oldPhoneNumber}) async {
  final db = await getDatabase();

  await db.update(
    contactsTableName,
    {
      'phoneNumber': newContact.phoneNumber,
      'name': newContact.name,
      'imagePath': newContact.imagePath
    },
    where: 'phoneNumber = ?',
    whereArgs: [oldPhoneNumber],
  );
}

Future<void> updateRecentsInDb(
    {required String newPhoneNumber, required String oldPhoneNumber}) async {
  final db = await getDatabase();
  await db.update(
    recentsTableName,
    {'phoneNumber': newPhoneNumber},
    where: 'phoneNumber = ?',
    whereArgs: [oldPhoneNumber],
  );
}

Future<void> deleteContactsFromDb({required String phoneNumber}) async {
  final db = await getDatabase();

  await db.delete(
    contactsTableName,
    where: 'phoneNumber = ?',
    whereArgs: [phoneNumber],
  );
}

Future<List<Map<String, Object?>>> readRecentsFromDb(
    {sql.Database? db, String? whereId}) async {
  db ??= await getDatabase();

  if (whereId != null) {
    return await db
        .query(recentsTableName, where: 'id = ?', whereArgs: [whereId]);
  }
  return await db.query(recentsTableName);
}

Future<void> updateRecentInDb(
    {required String complexMessageJsonString,
    required DateTime recentCallTime}) async {
  final db = await getDatabase();
  db.update(
    recentsTableName,
    {
      'messageJson': complexMessageJsonString,
    },
    where: 'callTime = ?',
    whereArgs: [recentCallTime.toString()],
  );
}

Future<void> insertRecentIntoDb({required Recent newRecent}) async {
  final db = await getDatabase();
  db.insert(
    recentsTableName,
    {
      'id': newRecent.id,
      'messageJson': newRecent.regularMessage == null
          ? newRecent.complexMessage!.complexMessageJsonString
          : newRecent.regularMessage!.toJsonString,
      'callTime': newRecent.callTime.toString(),
      'phoneNumber': newRecent.contact.phoneNumber,
      'categoryName': newRecent.category.name,
      'messageType': newRecent.regularMessage == null ? 'complex' : 'regular',
      'canBeViewed': newRecent.canBeViewed ? 1 : 0,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

Future<void> insertAccessRequestIntoDb(
    {required String recentId, required bool isSent}) async {
  final db = await getDatabase();
  await db.insert(
    accessRequestsTableName,
    {
      'recentId': recentId,
      'time': DateTime.now().toString(),
      'isSent': isSent ? 1 : 0,
    },
  );
}

Future<void> deleteAccessRequestFromDb({required String recentId}) async {
  final db = await getDatabase();
  await db.delete(
    accessRequestsTableName,
    where: 'recentId = ?',
    whereArgs: [recentId],
  );
}

Future<List<Map<String, Object?>>> readAccessRequestsFromDb(
    {required bool isSent}) async {
  final db = await getDatabase();
  return db.query(accessRequestsTableName,
      where: 'isSent = ?', whereArgs: [isSent ? 1 : 0]);
}
