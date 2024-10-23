import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ltrc/data/providers/all_provider.dart';
import '../models/word_phrase_sentence_model.dart';

class WordPhraseSentenceProvider {
  Database? _database;

  // Singleton instance of WordPhraseSentenceProvider
  static final WordPhraseSentenceProvider _instance = WordPhraseSentenceProvider._internal();

  factory WordPhraseSentenceProvider() {
    return _instance;
  }

  WordPhraseSentenceProvider._internal();
  static const String tableName = 'WordPhraseSentence';
  
  // Define constants for the database columns
  static const String databaseWordPhraseSentenceId = 'id';
  static const String databaseWord = 'word';
  static const String databasePhrase = 'phrase';
  static const String databaseDefinition = 'definition';
  static const String databaseSentence = 'sentence';
  static const String databasePhrase2 = 'phrase2';
  static const String databaseDefinition2 = 'definition2';
  static const String databaseSentence2 = 'sentence2';
    
  /// Fetch the singleton instance of the database, checking if it is closed
  Future<Database> get database async {
    if (AllProvider.isDbClosed) {
      throw Exception('Database is closed and cannot be accessed.');
    }    
    _database ??= await AllProvider().database;
    return _database!;
  }

  Future<void> addWordPhraseSentence({required WordPhraseSentence wordphrasesentence}) async {
    // final Database db = await getDBConnect();
    final Database db = await database;
    await db.insert(
      tableName,
      wordphrasesentence.toMap(), // Ensures the model has a `toMap()` method
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Fetch WordPhraseSentence by ID
  Future<WordPhraseSentence?> getWordPhraseSentenceById({required int inputWordPhraseSentenceId}) async {
    // final Database db = await getDBConnect();
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      columns: ["*"],
      where: "$databaseWordPhraseSentenceId=?",
      whereArgs: [inputWordPhraseSentenceId]
    );
    if (maps.isEmpty) {
      debugPrint("No word phrase sentence found for id: $inputWordPhraseSentenceId");
      return null;
    }
    return WordPhraseSentence(
      id: maps[0][databaseWordPhraseSentenceId],
      word: maps[0][databaseWord],
      phrase: maps[0][databasePhrase],
      definition: maps[0][databaseDefinition],
      sentence: maps[0][databaseSentence],
      phrase2: maps[0][databasePhrase2],
      definition2: maps[0][databaseDefinition2],
      sentence2: maps[0][databaseSentence2],      
    );
  }

  /// Fetch WordPhraseSentence by Word
  Future<WordPhraseSentence> getWordPhraseSentenceByWord({required String inputWord}) async {
    try {
      // final Database db = await getDBConnect();
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        columns: ["*"],
        where: "$databaseWord=?",
        whereArgs: [inputWord]
      );

      if (maps.isNotEmpty) {
        return WordPhraseSentence(
          id: maps[0][databaseWordPhraseSentenceId],
          word: maps[0][databaseWord],
          phrase: maps[0][databasePhrase],
          definition: maps[0][databaseDefinition],
          sentence: maps[0][databaseSentence],
          phrase2: maps[0][databasePhrase2],
          definition2: maps[0][databaseDefinition2],
          sentence2: maps[0][databaseSentence2],      
        );
      } else {
        // Handle the case where no results are found
        debugPrint("No word phrase sentence found for word: $inputWord");
        // Return a default or error object, or throw a custom exception as needed
        return WordPhraseSentence.error(); // Ensure `error()` is implemented in the model
      }
    } catch (e) {
      // Log the error or handle it as needed
      debugPrint("Error fetching word phrase sentence for word: $inputWord. Error: $e");
      // Return a default or error object, or re-throw the exception
      return WordPhraseSentence.error(); // Ensure `error()` is implemented in the model
    }
  }

  // For testing 多音字
  Future<List<Map<String, dynamic>>> readEntries() async {
    try {
      // final Database db = await getDBConnect();
      final Database db = await database;
      List<Map<String, dynamic>> entries = await db.query('WordPhraseSentence', limit: 10);
      return entries;
    } catch (e) {
      debugPrint("Error reading entries: $e");
      return [];
    }
  }

  Future<int> getMaxId() async {
    // final Database db = await getDBConnect();
    final Database db = await database;
    int maxId = Sqflite.firstIntValue(await db.rawQuery('SELECT MAX(id) FROM $tableName')) ?? 0;
    return maxId;
  }  

  /// Closes the database connection and disposes the provider
  Future<void> dispose() async {
    await AllProvider().closeDb();
    _database = null;
  }
}
