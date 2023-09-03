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
    String newPath = join(await getDatabasesPath(), 'words.sqlite');
    final exist = await databaseExists(newPath);
    if (!exist) {
      try {
        ByteData data = await rootBundle
            .load(join("assets/data_files", "vocabulary.sqlite"));
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(newPath).writeAsBytes(bytes, flush: true);
      } catch (e) {
        debugPrint('Failed to write bytes to the file at $newPath. Error: $e');
        throw Exception('Failed to write bytes to the file. Error: $e');
      }
    }
    database ??= await initDatabase();
    return database!;
  }

  static String tableName = 'vocabulary_utf8';

  // Define constants for database
  static const String databaseWord = 'word';
  static const String databaseVocab1 = 'vocab_1';
  static const String databaseMeaning1 = 'meaning_1';
  static const String databaseSentence1 = 'sentence_1';
  static const String databaseVocab2 = 'vocab_2';
  static const String databaseMeaning2 = 'meaning_2';
  static const String databaseSentence2 = 'sentence_2';

  static Future<Database> initDatabase() async =>
      database ??= await openDatabase(
        join(await getDatabasesPath(), 'words.sqlite'),
        version: 1,
      );

  static Future<void> addWord(Word word) async {
    final Database db = await getDBConnect();
    await db.insert(
      tableName,
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Word> getWord({required String inputWord}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> tmp =
        await db.rawQuery("PRAGMA table_info($tableName)");
    debugPrint(tmp.toString());
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        columns: [
          databaseWord,
          databaseVocab1,
          databaseMeaning1,
          databaseSentence1,
          databaseVocab2,
          databaseMeaning2,
          databaseSentence2
        ],
        where: "$databaseWord = ?",
        whereArgs: [inputWord]);
    return Word(
      word: maps[0][databaseWord],
      vocab1: maps[0][databaseVocab1],
      meaning1: maps[0][databaseMeaning1],
      sentence1: maps[0][databaseSentence1],
      vocab2: maps[0][databaseVocab2],
      meaning2: maps[0][databaseMeaning2],
      sentence2: maps[0][databaseSentence2],
    );
  }

  static void closeDb() async{
    await deleteDatabase(
      join(await getDatabasesPath(), 'words.sqlite')
    );
  }
}
