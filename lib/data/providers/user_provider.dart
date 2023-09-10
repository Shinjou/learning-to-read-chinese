import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/user_model.dart';

class UserProvider {
  static Database? database;
  static Future<Database> getDBConnect() async {
    database ??= await initDatabase();
    return database!;
  }

  static String tableName = 'users';
  
  // Define constants for database
  static const String databaseAccount = 'account';
  static const String databasePassword = 'password';
  static const String databaseUserName = 'username';
  static const String databaseSafetyQuestionId1 = 'safetyQuestionId1';
  static const String databaseSafetyAnswer1 = 'safetyAnswer1';
  static const String databaseSafetyQuestionId2 = 'safetyQuestionId2';
  static const String databaseSafetyAnswer2 = 'safetyAnswer2';
  static const String databaseGrade = 'grade';
  static const String databasePublisher = 'publisher';


  static Future<Database> initDatabase() async =>
    database ??= await openDatabase(
      join(await getDatabasesPath(), 'users.sqlite'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $tableName($databaseAccount TEXT PRIMARY KEY, $databasePassword TEXT, $databaseUserName TEXT, $databaseSafetyQuestionId1 INTEGER, $databaseSafetyAnswer1 TEXT, $databaseSafetyQuestionId2 INTEGER, $databaseSafetyAnswer2 TEXT, $databaseGrade INTEGER, $databasePublisher TEXT)",
        );
      },
      version: 1,
    );

  static Future<void> addUser({required User user}) async {
    final Database db = await getDBConnect();
    await db.insert(
      tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
    
  static Future<User> getUser({required String inputAccount}) async {
    final Database db = await getDBConnect();
    try {
      final List<Map<String, dynamic>> maps = await db.query(tableName,
        columns: [databaseAccount, databasePassword, databaseUserName, databaseSafetyQuestionId1, databaseSafetyAnswer1, databaseSafetyQuestionId2, databaseSafetyAnswer2, databaseGrade, databasePublisher],
        where: " $databaseAccount = ? ",
        whereArgs: [inputAccount]
      );
      return User(
        account: maps[0][databaseAccount],
        password: maps[0][databasePassword],
        username: maps[0][databaseUserName],
        safetyQuestionId1: maps[0][databaseSafetyQuestionId1],
        safetyAnswer1: maps[0][databaseSafetyAnswer1],
        safetyQuestionId2: maps[0][databaseSafetyQuestionId2],
        safetyAnswer2: maps[0][databaseSafetyAnswer2],
        grade: maps[0][databaseGrade],
        publisher: maps[0][databasePublisher],
      );
    } catch (e) {
      throw("[Provider] get user error: $e");
    }
  }

  static Future<List<String>> getAllUserAccounts() async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: [databaseAccount],
    );
    return List.generate(maps.length, (i) {
      return maps[i][databaseAccount];
    });
  }

  static Future<void> updateUser({required User user}) async {
    final Database db = await getDBConnect();
    await db.update(
      tableName,
      user.toMap(),
      where: " $databaseAccount = ? ",
      whereArgs: [user.account]
    );
  }

  static Future<void> deleteUser({required String inputAccount}) async {
    final Database db = await getDBConnect();
    await db.delete(tableName,
      where: " $databaseAccount = ? ",
      whereArgs: [inputAccount]
    );
  }

  static Future<void> closeDb() async {
    database = null;
    await deleteDatabase(
      join(await getDatabasesPath(), 'users.sqlite')
    );
  }
}
