import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class AllProvider {
  static Database? _database;
  static bool dbExists = false;  

  static const String _dbName = 'all.sqlite';  
  static const int _dbNewVersion = 99;  // Always upgrade to the latest version

  /// Gets the database instance, initializing if necessary.
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

  /// Initializes the database if it doesn't exist or has the wrong version.
  static Future<Database> _initDatabase() async {
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

      // Check and potentially upgrade the database version
      int currentVersion = await _database!.getVersion();
      debugPrint('$_dbName: New version $_dbNewVersion, Current: $currentVersion');
      if (currentVersion < _dbNewVersion) {
        debugPrint('Upgrading $_dbName from version $currentVersion to $_dbNewVersion ...');
        // If an upgrade is needed, copy the DB from assets
        await closeDb();
        await _copyDbFromAssets(dbPath);
        _database = await openDatabase(dbPath);
        debugPrint('Upgrade $_dbName successfully to version $_dbNewVersion');
      }
      
      return _database!;
    } catch (e) {
      debugPrint('Error initializing $_dbName: $e');
      rethrow;
    }
  }

  /// Copies the database from the assets folder into the device's app directory.
  static Future<void> _copyDbFromAssets(String dbPath) async {
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
  static Future<void> closeDb() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Retrieves the current version of the all.sqlite database.
  static Future<int> getCurrentDatabaseVersion() async {
    final db = await database;
    return await db.getVersion(); // Returns the current version of the opened database
  }
  
}

