import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import '../models/word_status_model.dart';

class WordStatusProvider {
  Database? _database;

  // Singleton pattern for WordStatusProvider
  static final WordStatusProvider _instance = WordStatusProvider._internal();

  factory WordStatusProvider() {
    return _instance;
  }

  WordStatusProvider._internal();

  static const String tableName = 'wordStatus';

  // Define constants for the database columns
  static const String databaseId = 'id';
  static const String databaseUserAccount = 'userAccount';
  static const String databaseWord = 'word';
  static const String databaseLearned = 'learned';
  static const String databaseLiked = 'liked';

  /// Fetch the singleton instance of the database from UserProvider, checking if it is closed
  Future<Database> get database async {
    if (UserProvider.isDbClosed) {
      throw Exception('Database is closed and cannot be accessed.');
    }
    _database ??= await UserProvider().database;
    return _database!;
  }

  /// Adds a word status to the database
  Future<void> addWordStatus({required WordStatus status}) async {
    final Database db = await database;
    await db.insert(
      tableName,
      status.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Adds multiple word statuses to the database
  Future<void> addWordsStatus({required List<WordStatus> statuses}) async {
    final Database db = await database;

    // Batch insertion
    Batch batch = db.batch();
    for (var status in statuses) {
      batch.insert(
        tableName,
        status.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    // Commit the batch with no result
    await batch.commit(noResult: true);
  }  
  
  /// Fetches the word status for a given word and account
  Future<WordStatus> getWordStatus({required String word, required String account}) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      columns: [databaseId, databaseUserAccount, databaseWord, databaseLearned, databaseLiked],  // Select only necessary columns
      where: "$databaseUserAccount = ? and $databaseWord = ?",
      whereArgs: [account, word]
    );
    
    if (maps.isNotEmpty) {
      return WordStatus(
        id: maps[0][databaseId],
        userAccount: maps[0][databaseUserAccount],
        word: maps[0][databaseWord],
        learned: (maps[0][databaseLearned] == 1),
        liked: (maps[0][databaseLiked] == 1)
      );
    } else {
      throw Exception('No word status found for $word and account $account');
    }
  }

  /// Fetches word statuses for a list of words and an account
  Future<List<WordStatus>> getWordsStatus({required List<String> words, required String account}) async {
    final Database db = await database;
    List<WordStatus> statuses = [];

    for (var word in words) {
      List<Map<String, dynamic>> maps = await db.query(
        tableName,
        columns: [databaseId, databaseUserAccount, databaseWord, databaseLearned, databaseLiked], // Select only necessary columns
        where: "$databaseUserAccount = ? and $databaseWord = ?",
        whereArgs: [account, word]
      );

      if (maps.isNotEmpty) {
        statuses.add(
          WordStatus(
            id: maps[0][databaseId],
            userAccount: maps[0][databaseUserAccount],
            word: maps[0][databaseWord],
            learned: (maps[0][databaseLearned] == 1),
            liked: (maps[0][databaseLiked] == 1)
          )
        );
      }
    }

    return statuses;
  }

  /// Fetches liked word statuses for a specific account
  Future<List<WordStatus>> getLikedWordsStatus({required String account}) async {
    final Database db = await database;
    List<WordStatus> statuses = [];

    // Select only the necessary columns
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      columns: [databaseId, databaseUserAccount, databaseWord, databaseLearned, databaseLiked],  // Only fetch required columns
      where: "$databaseUserAccount = ? and $databaseLiked = ?",
      whereArgs: [account, 1]
    );

    for (var entry in maps) {
      statuses.add(
        WordStatus(
          id: entry[databaseId],
          userAccount: entry[databaseUserAccount],
          word: entry[databaseWord],
          learned: (entry[databaseLearned] == 1),
          liked: (entry[databaseLiked] == 1)
        )
      );
    }

    return statuses;
  }

  /// Updates a word status in the database
  Future<void> updateWordStatus({required WordStatus status}) async {
    final Database db = await database;
    await db.update(
      tableName,
      status.toMapWithId(),
      where: "$databaseId = ?",
      whereArgs: [status.id]
    );
  }

  // Nothing to close in this provider, so no need for dispose
}
