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

  static const String _dbName = 'users.sqlite';
    static const int _dbVersion = 5; // 8/29/2024
  static const String _wordStatusTable = 'wordStatus';

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> getDBConnect() async {
    if (!dbExists){
      _database = await _initDatabase();
    }
    return _database!;
  }  

  static Future<Database?> _initDatabase() async {
    try {
      String dbPath = join(await getDatabasesPath(), _dbName);
      debugPrint('Path to $_dbName: $dbPath');

      bool dbExists = await databaseExists(dbPath);
      if (!dbExists) {
        await _copyDbFromAssets(dbPath);
        dbExists = true;
        _database = await openDatabase(dbPath);
        debugPrint('$_dbName copied from assets.');
        return _database!;
      } 

      // Open the database
      _database = await openDatabase(dbPath);

      // Checking and potentially upgrading the database version
      int currentVersion = await _database!.getVersion();
      if (currentVersion < _dbVersion) {
        debugPrint('Upgrading $_dbName from version $currentVersion to $_dbVersion ...');
        // users.sqlite如果需要 upgrade，需要個別處理
        // Ver 4，新增“鸚”一字。先刪掉舊的，再新增新的。
        try {
          await deleteWord(db: _database, userAccount: 'tester', word: '鸚');
          await addWord(db: _database, userAccount: 'tester', word: '鸚', learned: 1, liked: 1);
          /* 8/29/2024 can not add user testerbpmf
          // The following code will cause a disk I/O error
          await _addUser(db: _database, user: User(
            account: 'testerbpmf',
            password: '1234',
            username: 'testerbpmf',
            safetyQuestionId1: 1,
            safetyAnswer1: '1234',
            safetyQuestionId2: 2,
            safetyAnswer2: '1234',
            grade: 1,
            semester: '上',
            publisher: '康軒',
          ));
          // the following code will cause a loop of _initDatabase() and upgrade
          await addUser(
            user: User(
              account: 'testerbpmf',
              password: '1234',
              username: 'testerbpmf',
              safetyQuestionId1: 1,
              safetyAnswer1: '1234',
              safetyQuestionId2: 2,
              safetyAnswer2: '1234',
              grade: 1,
              semester: '上',
              publisher: '康軒',
            ),
          );       
          */
          await _database!.setVersion(_dbVersion);  
          debugPrint('Upgrade $_dbName successfully to version $_dbVersion');
        } catch (e) {
          throw ("Error in upgrade users.sqlite: $e");
        }
      } else {
        debugPrint('Database $_dbName opened successfully...');
      }

      return _database!;
    } catch (e) {
      debugPrint('Error initializing $_dbName: $e');
      rethrow; // Consider handling this more gracefully
    }
  }

  static Future<void> _copyDbFromAssets(String dbPath) async {
    try {
      debugPrint('Copying $_dbName from assets/data_files/...');
      ByteData data = await rootBundle.load(join('assets/data_files/', _dbName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
      debugPrint('Copy of $_dbName to $dbPath completed successfully.');
    } catch (e) {
      debugPrint('Failed to copy $_dbName from assets to $dbPath. Error: $e');
      // Depending on your use case, you might want to rethrow the error,
      // return a failure status, or attempt a recovery operation here.
      // For example, to rethrow the error, uncomment the following line:
      rethrow;
    }
  }

  static Future<void> addWord({
    required Database? db,
    required String userAccount,
    required String word,
    required int learned,
    required int liked,
  }) async {
    try {
      await db?.insert(
        _wordStatusTable, // Assuming 'wordStatus' is the correct table name
        {
          'userAccount': userAccount,
          'word': word,
          'learned': learned,
          'liked': liked,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint("Word $word added successfully");
    } catch (e) {
      debugPrint('An error occurred while inserting the word: $e');
    }
  }

  static Future<void> deleteWord({
    required Database? db,
    required String userAccount,
    required String word,
  }) async {
    try {
      await db?.delete(
        _wordStatusTable,
        where: 'userAccount = ? AND word = ?', // Define the WHERE clause
        whereArgs: [userAccount, word], // Provide the values for the WHERE clause
      );
      debugPrint("Word $word deleted successfully");
    } catch (e) {
      debugPrint('An error occurred while deleting the word: $e'); // Corrected error message
    }
  }

  static Future<void> addUser({required User user}) async {
    try {
      final Database db = await getDBConnect();
      await db.insert(
        tableName,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint("User $user added successfully");
    } catch (e) {
      debugPrint('Error while adding a new user: $e');
    }
  }
  /*
  static Future<void> _addUser({
    required Database? db,
    required User user,
  }) async {
    try {
      // final Database db = await getDBConnect();
      await db?.insert(
        tableName,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint("User $user added successfully");
    } catch (e) {
      debugPrint('Error while adding a new user: $e');
    }
  }
  */
  
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
    try {
      final Database db = await getDBConnect();
      await db.delete(tableName,
        where: " $databaseAccount = ? ", 
        whereArgs: [inputAccount]
      );
      await db.rawDelete("DELETE FROM wordStatus WHERE userAccount = ?", [inputAccount]);
    } catch (e) {
      // Error reporting
      debugPrint('Error deleting user $inputAccount: $e');
      // Consider using more sophisticated error reporting if available in your app
    }
  }

  static Future<void> closeDb() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

