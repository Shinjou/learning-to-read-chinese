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
  static const int _dbVersion = 2;  

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
      debugPrint('Opening all.sqlite at $dbPath');

      // Check if the database exists
      dbExists = await databaseExists(dbPath);

      if (!dbExists) {
        // Copy from assets if the database doesn't exist
        debugPrint('Copying $_dbName from assets/data_files/...');
        ByteData data = await rootBundle.load(join('assets/data_files/', _dbName));
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);
      } else {
        debugPrint('Opening existing all.sqlite ...');
      }

      // Open the database
      return await openDatabase(
        dbPath,
        version: _dbVersion,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('Error initializing all.sqlite: $e');
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

  static Future<void> closeDb() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

