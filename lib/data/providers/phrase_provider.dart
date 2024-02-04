import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ltrc/data/providers/all_provider.dart';

import '../models/phrase_model.dart';

class PhraseProvider {
  static Database? database;

  static Future<Database> getDBConnect() async {
    database ??= await AllProvider.getDBConnect();
    return database!;
  }

  static String tableName = 'Phrases';
  
  // Define constants for database
  static const String databaseId = 'id';
  static const String databasePhrase = 'phrase';
  static const String databaseDefinition = 'definition';
  static const String databaseSentence = 'sentence';

  
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
