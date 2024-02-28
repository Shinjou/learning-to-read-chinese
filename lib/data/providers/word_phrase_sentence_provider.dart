import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ltrc/data/providers/all_provider.dart';

import '../models/word_phrase_sentence_model.dart';

class WordPhraseSentenceProvider {
  static Database? database;

  static Future<Database> getDBConnect() async {
    database ??= await AllProvider.getDBConnect();
    return database!;
  }

  static String tableName = 'WordPhraseSentence';
  
  // Define constants for database
  static const String databaseWordPhraseSentenceId = 'id';
  static const String databaseWord = 'word';
  static const String databasePhrase = 'phrase';
  static const String databaseDefinition = 'definition';
  static const String databaseSentence = 'sentence';
  static const String databasePhrase2 = 'phrase2';
  static const String databaseDefinition2 = 'definition2';
  static const String databaseSentence2 = 'sentence2';
  
  static Future<void> addWordPhraseSentence({required WordPhraseSentence wordphrasesentence}) async {
    final Database db = await getDBConnect();
    await db.insert(
      tableName,
      wordphrasesentence.toMap(), // How does this work?
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }


  static Future<WordPhraseSentence> getWordPhraseSentenceById({required int inputWordPhraseSentenceId}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: ["*"],
      where: "$databaseWordPhraseSentenceId=?",
      whereArgs: [inputWordPhraseSentenceId]
    );
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

  static Future<WordPhraseSentence> getWordPhraseSentenceByWord({required String inputWord}) async {
    try {
      final Database db = await getDBConnect();
      final List<Map<String, dynamic>> maps = await db.query(tableName,
        columns: ["*"],
        where: "$databaseWord=?",
        whereArgs: [inputWord]
      );

      if (maps.isNotEmpty) {
        // Assuming maps is not empty, return the first result as the WordPhraseSentence
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
        return WordPhraseSentence.error(); // Implement this method to return a default/error instance
      }
    } catch (e) {
      // Log the error or handle it as needed
      debugPrint("Error fetching word phrase sentence for word: $inputWord. Error: $e");
      // Return a default or error object, or re-throw the exception
      return WordPhraseSentence.error(); // Implement this method to return a default/error instance
    }
  }


  static Future<void> closeDb() async{
    database = null;
    await deleteDatabase(
      join(await getDatabasesPath(), 'all.sqlite')
    );
  }
}
