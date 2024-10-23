import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class AllProvider {
  // Singleton pattern - single instance of Database
  static final AllProvider _instance = AllProvider._internal();
  
  factory AllProvider() {
    return _instance;
  }

  AllProvider._internal();

  static Database? _database;
  static bool dbExists = false;
  static bool isDbClosed = true;  // Flag to check if the database is closed

  static const String _dbName = 'all.sqlite';  
  static const int _dbNewVersion = 10; // Always upgrade to the latest version

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

  /// Initializes the database if it doesn't exist or has the wrong version.
  Future<Database?> _initDatabase() async {
    try {
      String dbPath = join(await getDatabasesPath(), _dbName);
      debugPrint('Path to $_dbName: $dbPath');

      dbExists = await databaseExists(dbPath);
      if (!dbExists) {
        await _copyDbFromAssets(dbPath);
        dbExists = true;
        debugPrint('$_dbName copied from assets.');
      } 

      // Open the database
      _database = await openDatabase(dbPath);

      // Mark the database as open
      isDbClosed = false;

      // Check and potentially upgrade the database version
      int currentVersion = await _database!.getVersion();
      debugPrint('$_dbName: New version $_dbNewVersion, Current: $currentVersion');
      if (currentVersion < _dbNewVersion) {
        debugPrint('Upgrading $_dbName from version $currentVersion to $_dbNewVersion ...');
        // If an upgrade is needed, copy the DB from assets
        await _upgradeDatabase(dbPath);
      }
      
      return _database;
    } catch (e) {
      debugPrint('Error initializing $_dbName: $e');
      return null;
    }
  }

  Future<void> _upgradeDatabase(String dbPath) async {
    // Close current DB and replace with the new one from assets
    await closeDb();
    await _copyDbFromAssets(dbPath);
    _database = await openDatabase(dbPath);
    debugPrint('Database upgraded to version $_dbNewVersion');
    isDbClosed = false;  // Mark the database as open again
  }  

  /// Copies the database from the assets folder into the device's app directory.
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

  /// Closes the database if it's open.
  Future<void> closeDb() async {
    if (_database != null) {
      debugPrint('Closing AllProvider database...');
      await _database!.close();
      _database = null;
      isDbClosed = true;  // Mark the database as closed
      debugPrint('AllProvider database closed.');
    }
  }

  /// Retrieves the current version of the all.sqlite database.
  Future<int> getCurrentDatabaseVersion() async {
    final db = await database;
    return await db.getVersion(); // Returns the current version of the opened database
  }
}
