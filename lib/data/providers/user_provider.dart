import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';

class UserProvider {
  static Database? _database;
  static bool dbExists = false;  
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

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> getDBConnect() async {
    if (!dbExists){
      _database ??= await _initDatabase();
    }
    return _database!;
  }  

  static Future<Database> _initDatabase() async {
    try {
      String dbPath = join(await getDatabasesPath(), _dbName);
      debugPrint('Opening users database at $dbPath');

      // Check if the database exists
      dbExists = await databaseExists(dbPath);

      if (!dbExists) {
        // Copy from assets if the database doesn't exist
        debugPrint('Copying $_dbName from assets/data_files/...');
        ByteData data = await rootBundle.load(join('assets/data_files/', _dbName));
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);
      } else {
        debugPrint('Opening existing database...');
      }

      // Open the database
      return await openDatabase(
        dbPath,
        version: _dbVersion,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('Error initializing the database: $e');
      rethrow;
    }
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
    if (oldVersion < newVersion) {
      // Example: if (oldVersion < 2) { await db.execute("ALTER TABLE ..."); }
      // Add other migration logic as needed
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
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

