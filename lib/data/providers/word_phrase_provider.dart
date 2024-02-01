import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class WordPhraseProvider {
  static Database? database;
  static Future<Database> getDBConnect() async {
    String newPath = join(await getDatabasesPath(), 'all.sqlite');
    final exist = await databaseExists(newPath);
    if (!exist) {
      try {
          ByteData data = await rootBundle.load(join("assets/data_files", "all.sqlite"));
          List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await File(newPath).writeAsBytes(bytes, flush: true);
      } 
      catch (e) {
        debugPrint('Failed to write bytes to the file at $newPath. Error: $e');
        throw Exception('Failed to write bytes to the file. Error: $e');
      }
    }
    database ??= await initDatabase();
    return database!;
  }

  static String tableName = 'WordPhrase';
  
  // Define constants for database
  static const String databaseWordId = 'word_id';
  static const String databasePhraseId = 'phrase_id';

  static Future<Database> initDatabase() async =>
    database ??= await openDatabase(
      join(await getDatabasesPath(), 'all.sqlite'),
      version: 2,
    );

  static Future<List<int>> getPhrasesId({required int inputWordId}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: ["*"],
      where: "$databaseWordId=?",
      whereArgs: [inputWordId]
    );
    return List.generate(maps.length, (i) => 
      maps[i][databasePhraseId]
    );
  }

  static Future<void> closeDb() async{
    database = null;
    await deleteDatabase(
      join(await getDatabasesPath(), 'all.sqlite')
    );
  }
}
