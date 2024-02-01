import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ltrc/data/providers/all_provider.dart';

import '../models/word_model.dart';

class WordProvider {
  static Database? database;
  static Future<Database> getDBConnect() async {
    database ??= await AllProvider.getDBConnect();
    return database!;
  }

  static String tableName = 'Words';
  
  // Define constants for database
  static const String databaseId = 'id';
  static const String databaseWord = 'word';
  static const String databasePhoneticTone = 'phonetic_tone';
  static const String databasePhonetic = 'phonetic';
  static const String databaseTone = 'tone';
  static const String databaseShapeSymbol = 'shape_symbol';
  static const String databaseSoundSymbol = 'sound_symbol';
  static const String databaseStrokes = 'strokes';
  static const String databaseCommon = 'common';


  static Future<void> addWord(Word word) async {
    final Database db = await getDBConnect();
    await db.insert(
      tableName,
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<Word> getWord({required String inputWord}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: ["*"],
      where: "$databaseWord=?",
      whereArgs: [inputWord]
    );
    return Word(
      id: maps[0][databaseId],
      word: maps[0][databaseWord],
      phoneticTone: maps[0][databasePhoneticTone],
      phonetic: maps[0][databasePhonetic],
      tone: maps[0][databaseTone],
      shapeSymbol: maps[0][databaseShapeSymbol],
      soundSymbol: maps[0][databaseSoundSymbol],
      strokes: (maps[0][databaseStrokes].runtimeType == String) ? 0 : maps[0][databaseStrokes],
      common: (maps[0][databaseCommon].runtimeType == String) ? 0 : maps[0][databaseCommon],
    );
  }

  static Future<void> closeDb() async{
    database = null;
    await deleteDatabase(
      join(await getDatabasesPath(), 'all.sqlite')
    );
  }
}
