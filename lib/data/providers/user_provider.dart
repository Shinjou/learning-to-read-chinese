import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';

class UserProvider {
  // Singleton pattern - single instance of Database
  static final UserProvider _instance = UserProvider._internal();
  
  factory UserProvider() {
    return _instance;
  }

  UserProvider._internal();

  static Database? _database;
  static bool dbExists = false;  
  static bool isDbClosed = true;  // Flag to track the database state
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
  static const int _dbNewVersion = 10; 
  static const String _wordStatusTable = 'wordStatus';

  /// Gets the singleton database instance, initializing if necessary.
  Future<Database> get database async {
    if (_database != null && !isDbClosed) {
      return _database!;
    }

    // Try initializing the database
    _database = await _initDatabase();

    if (_database == null) {
      throw Exception('Failed to initialize the database.');
    }

    return _database!;
  }

  Future<Database?> _initDatabase() async {
    try {
      String dbPath = join(await getDatabasesPath(), _dbName);
      debugPrint('Path to $_dbName: $dbPath');

      dbExists = await databaseExists(dbPath);
      if (!dbExists) {
        await _copyDbFromAssets(dbPath);
        dbExists = true;
        _database = await openDatabase(dbPath);
        debugPrint('$_dbName copied from assets.');
        isDbClosed = false;  // Mark database as open

        // Create index on wordStatus table
        await _createIndexes(_database!);        
        return _database;
      }

      _database = await openDatabase(dbPath);
      isDbClosed = false;  // Mark database as open
      // Create index on wordStatus table
      await _createIndexes(_database!);
      // Check and potentially upgrade the database version
      int currentVersion = await _database!.getVersion();
      if (currentVersion < _dbNewVersion) {
        await _performUpgrade(_database!, currentVersion);
      }

      return _database!;
    } catch (e) {
      debugPrint('Error initializing $_dbName: $e');
      return null;
    }
  }

  Future<void> _performUpgrade(Database db, int currentVersion) async {
    try {
      debugPrint('Upgrading $_dbName from version $currentVersion to $_dbNewVersion...');
      await deleteUserWord(db: db, userAccount: 'tester', word: '鸚');
      await addUserWord(db: db, userAccount: 'tester', word: '鸚', learned: 1, liked: 1);
      
      bool userBpmfExists = await checkIfAccountExists('testerbpmf');
      if (!userBpmfExists) {
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
      }         
      // Ensure indexes are created after upgrade
      await _createIndexes(db);

      // Update the database version
      await db.setVersion(_dbNewVersion);
      debugPrint('Upgrade $_dbName successfully from $currentVersion to $_dbNewVersion');
    } catch (e) {
      debugPrint("Error in upgrading users.sqlite: $e");
    }
  }

  Future<void> _copyDbFromAssets(String dbPath) async {
    try {
      debugPrint('Copying $_dbName from assets/data_files/...');
      ByteData data = await rootBundle.load(join('assets/data_files/', _dbName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
      debugPrint('Copy of $_dbName to $dbPath completed successfully.');
    } catch (e) {
      debugPrint('Failed to copy $_dbName from assets to $dbPath. Error: $e');
      rethrow;
    }
  }

  // Create indexes for optimization
  Future<void> _createIndexes(Database db) async {
    try {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_word_user ON wordStatus (word, userAccount)');
      debugPrint('Index idx_word_user created on wordStatus table.');
    } catch (e) {
      debugPrint('Error creating index on wordStatus table: $e');
    }
  }  

  Future<int> getCurrentDatabaseVersion() async {
    final Database db = await database;
    return await db.getVersion(); // Returns the current version of the opened database
  }

  Future<void> addUserWord({
    required Database? db,
    required String userAccount,
    required String word,
    required int learned,
    required int liked,
  }) async {
    try {
      await db?.insert(
        _wordStatusTable,
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

  Future<void> deleteUserWord({
    required Database? db,
    required String userAccount,
    required String word,
  }) async {
    try {
      await db?.delete(
        _wordStatusTable,
        where: 'userAccount = ? AND word = ?',
        whereArgs: [userAccount, word],
      );
      debugPrint("Word $word deleted successfully");
    } catch (e) {
      debugPrint('An error occurred while deleting the word: $e');
    }
  }

  Future<void> addUser({required User user}) async {
    try {
      validateUser(user);
      final Database db = await database;
      await db.insert(
        tableName,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      debugPrint("User ${user.username} added successfully");
    } catch (e) {
      debugPrint('Error while adding a new user: $e');
      throw Exception('Failed to add user');
    }
  }

  void validateUser(User user) {
    if (user.account.isEmpty || user.password.isEmpty) {
      throw Exception('Account and password cannot be empty');
    }
  }  

  Future<User> getUser({required String inputAccount}) async {
    final Database db = await database;    
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

  Future<List<String>> getAllUserAccounts() async {
    final Database db = await database;    
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: [databaseAccount],
    );
    return List.generate(maps.length, (i) {
      return maps[i][databaseAccount];
    });
  }

  Future<void> updateUser({required User user}) async {
    final Database db = await database;
    await db.update(
      tableName, 
      user.toMap(),
        where: " $databaseAccount = ? ", 
      whereArgs: [user.account]
    );
  }

  Future<void> deleteUser({required String inputAccount}) async {
    try {
      final Database db = await database;
      await db.delete(tableName,
        where: " $databaseAccount = ? ", 
        whereArgs: [inputAccount]
      );
      await db.rawDelete("DELETE FROM wordStatus WHERE userAccount = ?", [inputAccount]);
    } catch (e) {
      debugPrint('Error deleting user $inputAccount: $e');
    }
  }

  Future<bool> checkIfAccountExists(String accountName) async {
    try {
      User user = await getUser(inputAccount: accountName);
      if (user.account == accountName) {
        return true;  // Account exists
      }
      return false;   // Account does not exist
    } catch (e) {
      debugPrint("[Provider] Error fetching user: $e");
      return false; 
    }
  }

  Future<void> closeDb() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      isDbClosed = true;  // Mark database as closed
    }
  }
}
