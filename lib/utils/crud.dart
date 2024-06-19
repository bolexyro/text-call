import 'package:sqflite/sqflite.dart' as sql;
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/utils/db_schema.dart';

const String contactsTableName = 'contacts';
const String recentsTableName = 'recents';
const String accessRequestsTableName = 'access_requests';

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
    conflictAlgorithm: sql.ConflictAlgorithm.ignore,
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

Future<void> updateRecentComplexMessageJsonStringInDb(
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
    conflictAlgorithm: sql.ConflictAlgorithm.ignore,
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
    conflictAlgorithm: sql.ConflictAlgorithm.replace,
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
