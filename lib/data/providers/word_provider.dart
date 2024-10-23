import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:ltrc/data/providers/all_provider.dart';
import '../models/word_model.dart';

class WordProvider {
  Database? _database;

  // Singleton pattern for WordProvider
  static final WordProvider _instance = WordProvider._internal();

  factory WordProvider() {
    return _instance;
  }

  WordProvider._internal();

  static const String tableName = 'Words';
  
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

  /// Fetch the singleton instance of the database, checking if it is closed
  Future<Database> get database async {
    if (AllProvider.isDbClosed) {
      throw Exception('Database is closed and cannot be accessed.');
    }
    _database ??= await AllProvider().database;
    return _database!;
  }

  /// Adds a word to the database
  Future<void> addWord(Word word) async {
    final Database db = await database;
    await db.insert(
      tableName,
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Fetches a word by its name
  Future<Word> getWord({required String inputWord}) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      columns: ["*"],
      where: "$databaseWord=?",
      whereArgs: [inputWord]
    );

    if (maps.isNotEmpty) {
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
    } else {
      throw Exception('No word found for $inputWord');
    }
  }

  /// Closes the database connection and disposes the provider
  Future<void> dispose() async {
    await AllProvider().closeDb();
    _database = null;
  }
}
