import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ltrc/data/providers/user_provider.dart';

import '../models/word_status_model.dart';

class WordStatusProvider {
  static Database? database;
  static Future<Database> getDBConnect() async {
    database ??= await UserProvider.getDBConnect();
    return database!;
  }

  static String tableName = 'wordStatus';
  
  // Define constants for database
  static const String databaseId = 'id';
  static const String databaseUserAccount = 'userAccount';
  static const String databaseWord = 'word';
  static const String databaseLearned = 'learned';
  static const String databaseLiked = 'liked';


  
  static Future<void> addWordStatus({required WordStatus status}) async {
    final Database db = await getDBConnect();
    await db.insert(
      tableName,
      status.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> addWordsStatus({required List<WordStatus> statuses}) async {
    final Database db = await getDBConnect();
    for ( var status in statuses ){
      await db.insert(
        tableName,
        status.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
    
  static Future<WordStatus> getWordStatus({required String word, required String account}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: [databaseId, databaseUserAccount, databaseWord, databaseLearned, databaseLiked],
      where: "$databaseUserAccount = ? and $databaseWord = ?",
      whereArgs: [account, word]
    );
    return WordStatus(
      id: maps[0][databaseId],
      userAccount: maps[0][databaseUserAccount],
      word: maps[0][databaseWord],
      learned: (maps[0][databaseLearned] == 1) ? true : false,
      liked: (maps[0][databaseLiked] == 1) ? true : false
    );
  }

  static Future<List<WordStatus>> getWordsStatus({required List<String> words, required String account}) async {
    final Database db = await getDBConnect();
    List<WordStatus> statuses = [];
    for (var word in words){
      List<Map<String, dynamic>> maps = await db.query(tableName,
        columns: [databaseId, databaseUserAccount, databaseWord, databaseLearned, databaseLiked],
        where: "$databaseUserAccount = ? and $databaseWord = ?",
        whereArgs: [account, word]
      );
      statuses.add(
        WordStatus(
          id: maps[0][databaseId],
          userAccount: maps[0][databaseUserAccount],
          word: maps[0][databaseWord],
          learned: (maps[0][databaseLearned] == 1) ? true : false,
          liked: (maps[0][databaseLiked] == 1) ? true : false
        )
      );
    }
    return statuses;
  }

  static Future<List<WordStatus>> getLikedWordsStatus({required String account}) async {
    final Database db = await getDBConnect();
    List<WordStatus> statuses = [];
    List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: ['*'],
      where: "$databaseUserAccount = ? and $databaseLiked = ?",
      whereArgs: [account, 1]
    );
    for (var entry in maps){
      statuses.add(
        WordStatus(
          id: entry[databaseId],
          userAccount: entry[databaseUserAccount],
          word: entry[databaseWord],
          learned: (entry[databaseLearned] == 1) ? true : false,
          liked: (entry[databaseLiked] == 1) ? true : false
        )
      );
    }
    return statuses;
  }

  static Future<void> updateWordStatus({required WordStatus status}) async {
    final Database db = await getDBConnect();
    await db.update(
      tableName,
      status.toMapWithId(),
      where: "$databaseId = ?",
      whereArgs: [status.id]
    );
  }

  static Future<void> closeDb() async {
    await deleteDatabase(join(await getDatabasesPath(), 'wordStatus.sqlite'));
  }
}
