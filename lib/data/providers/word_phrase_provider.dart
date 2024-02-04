import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ltrc/data/providers/all_provider.dart';

class WordPhraseProvider {
  static Database? database;
  static Future<Database> getDBConnect() async {
    database ??= await AllProvider.getDBConnect();
    return database!;
  }  

  static String tableName = 'WordPhrase';
  
  // Define constants for database
  static const String databaseWordId = 'word_id';
  static const String databasePhraseId = 'phrase_id';

  
  static Future<List<int>> getPhrasesId({required int inputWordId}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: ["*"],
      where: "$databaseWordId=?",
      whereArgs: [inputWordId]
    );
    return List.generate(maps.length, (i) => 
      maps[i][databasePhraseId]
    );
  }

  static Future<void> closeDb() async{
    database = null;
    await deleteDatabase(
      join(await getDatabasesPath(), 'all.sqlite')
    );
  }
}
