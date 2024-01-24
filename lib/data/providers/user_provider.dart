import 'dart:async';
import 'package:flutter/material.dart';
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
  static const String databaseSemester = 'semester';
  static const String databasePublisher = 'publisher';

  static const int _dbVersion = 3;
  static const String _dbName = 'users.sqlite';

  static Future<Database> initDatabase() async {
    try {
      String dbPath = join(await getDatabasesPath(), _dbName);
      debugPrint('init users.sqlite: $dbPath'); // Display the database path

      // Check if the database exists
      bool dbExists = await databaseExists(dbPath);

      if (!dbExists) {
        // If the database doesn't exist, create a new one
        debugPrint('No users.sqlite, create a new one...');
        return await _createDatabase(dbPath);
      } else {
        // If the database exists, open and check its version
        Database db = await openDatabase(dbPath);

        if (await _getDatabaseVersion(db) != _dbVersion) {
          // If the version is different, delete the current DB and create a new one
          await deleteDatabase(dbPath);
          return await _createDatabase(dbPath);
        } else {
          // If the version is the same, return the opened database
          return db;
        }
      }
    } catch (e) {
      print('Error initializing the database: $e');
      rethrow; // Re-throwing the error after logging it
    }
  }
  
  static Future<Database> _createDatabase(String path) async {
    try {
      return await openDatabase(
        path,
        onCreate: (db, version) async {
          // Create the table
          await db.execute(
            "CREATE TABLE $tableName($databaseAccount TEXT PRIMARY KEY, $databasePassword TEXT, $databaseUserName TEXT, $databaseSafetyQuestionId1 INTEGER, $databaseSafetyAnswer1 TEXT, $databaseSafetyQuestionId2 INTEGER, $databaseSafetyAnswer2 TEXT, $databaseGrade INTEGER, $databaseSemester TEXT, $databasePublisher TEXT)",
          );

          // Add a default user of tester for Apple 
          var defaultUser = User(
                            account: 'tester',
                            password: '1234',
                            safetyQuestionId1: 1,
                            safetyAnswer1: '1234',
                            safetyQuestionId2: 2,
                            safetyAnswer2: '1234',
                            grade: 1,
                            semester: '上',
                            publisher: '康軒',
                          );

          addUser(user: defaultUser).then((_) {
            debugPrint("User tester added successfully");
          }).catchError((error) {
            debugPrint("Failed to add user: $error");
          });
        },
        version: _dbVersion,
      );
    } catch (e) {
      print('Error creating the users.sqlite: $e');
      rethrow;
    }
  }

  static Future<int> _getDatabaseVersion(Database db) async {
    try {
      var result = await db.rawQuery('PRAGMA user_version');
      int version = result.isNotEmpty ? result[0]['user_version'] as int : 0;
      return version;
    } catch (e) {
      print('Error fetching the database version: $e');
      rethrow;
    }
  }

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
          columns: [
            databaseAccount,
            databasePassword,
            databaseUserName,
            databaseSafetyQuestionId1,
            databaseSafetyAnswer1,
            databaseSafetyQuestionId2,
            databaseSafetyAnswer2,
            databaseGrade,
            databaseSemester,
            databasePublisher
          ],
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
        semester: maps[0][databaseSemester],
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
