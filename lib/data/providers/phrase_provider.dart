import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/phrase_model.dart';

class PhraseProvider {
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

  static String tableName = 'Phrases';
  
  // Define constants for database
  static const String databaseId = 'id';
  static const String databasePhrase = 'phrase';
  static const String databaseDefinition = 'definition';
  static const String databaseSentence = 'sentence';

  static Future<Database> initDatabase() async =>
    database ??= await openDatabase(
      join(await getDatabasesPath(), 'all.sqlite'),
      version: 1,
    );

  static Future<void> addPhrase(Phrase phrase) async {
    final Database db = await getDBConnect();
    await db.insert(
      tableName,
      phrase.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<Phrase> getPhraseById({required int inputPhraseId}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: ["*"],
      where: "$databaseId=?",
      whereArgs: [inputPhraseId]
    );
    return Phrase(
      id: maps[0][databaseId],
      phrase: maps[0][databasePhrase],
      definition: maps[0][databaseDefinition],
      sentence: maps[0][databaseSentence],
    );
  }



  static Future<void> closeDb() async{
    database = null;
    await deleteDatabase(
      join(await getDatabasesPath(), 'all.sqlite')
    );
  }
}
