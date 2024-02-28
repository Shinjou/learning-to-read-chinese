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
  static const int _dbVersion = 4;  // 2/25/2024

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
      debugPrint('Path to $_dbName: $dbPath');

      bool dbExists = await databaseExists(dbPath);
      if (!dbExists) {
        await _copyDbFromAssets(dbPath);
        debugPrint('$_dbName copied from assets.');
      } 

      // Open the database
      _database = await openDatabase(dbPath);

      // Checking and potentially upgrading the database version
      int currentVersion = await _database!.getVersion();

      if (currentVersion < _dbVersion) {
        debugPrint('Upgrading $_dbName from version $currentVersion to $_dbVersion ...');
        // Copy the database from assets
        await closeDb();
        await _copyDbFromAssets(dbPath);
        _database = await openDatabase(dbPath);
        debugPrint('Upgrade $_dbName successfully...');
      }
      
      return _database!;
    } catch (e) {
      debugPrint('Error initializing $_dbName: $e');
      rethrow;
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

  static Future<void> closeDb() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

