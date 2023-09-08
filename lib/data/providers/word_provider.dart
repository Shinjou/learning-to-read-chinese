import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/word_model.dart';

class WordProvider {
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

  static Future<Database> initDatabase() async =>
    database ??= await openDatabase(
      join(await getDatabasesPath(), 'all.sqlite'),
      version: 1,
    );

  static Future<void> addWord(Word word) async {
    final Database db = await getDBConnect();
    await db.insert(
      tableName,
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
  // static Future<void> addWord(Word word) async {
  //   final Database db = await getDBConnect();
  //   await db.insert(
  //     tableName,
  //     word.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  static Future<Word> getWord({required String inputWord}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: ["*"],
      where: "$databaseWord=?",
      whereArgs: [inputWord]
    );
    return Word(
      id: maps[0][databaseId]
      word: maps[0][databaseWord],
      vocab1: maps[0][databasePhoneticTone],
      meaning1: maps[0][databasePhonetic],
      sentence1: maps[0][databaseTone],
      vocab2: maps[0][databaseShapeSymbol],
      meaning2: maps[0][databaseSoundSymbol],
      sentence2: maps[0][databaseStrokes],
      sentence2: maps[0][databaseCommon],
    );
  }
    
  // static Future<Word> getWord({required String inputWord}) async {
  //   final Database db = await getDBConnect();
  //   final List<Map<String, dynamic>> tmp = await db.rawQuery("PRAGMA table_info($tableName)");
  //   debugPrint(tmp.toString());
  //   final List<Map<String, dynamic>> maps = await db.query(tableName,
  //     columns: [databaseWord, databaseVocab1, databaseMeaning1, databaseSentence1, databaseVocab2, databaseMeaning2, databaseSentence2],
  //     where: "$databaseWord=?",
  //     whereArgs: [inputWord]
  //   );
  //   return Word(
  //     word: maps[0][databaseWord],
  //     vocab1: maps[0][databaseVocab1],
  //     meaning1: maps[0][databaseMeaning1],
  //     sentence1: maps[0][databaseSentence1],
  //     vocab2: maps[0][databaseVocab2],
  //     meaning2: maps[0][databaseMeaning2],
  //     sentence2: maps[0][databaseSentence2],
  //   );
  // }

  static void closeDb() async{
    await deleteDatabase(
      join(await getDatabasesPath(), 'words.sqlite')
    );
  }
}
