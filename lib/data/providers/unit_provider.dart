import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/unit_model.dart';

class UnitProvider {
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

  static String tableName = "TextBooks";
  
  // Define constants for database
  static const String databaseId = 'id';
  static const String databasePublisher = 'publisher';
  static const String databaseGrade = 'grade';
  static const String databaseSemester = 'semester';
  static const String databaseUnitId = 'unit_id';
  static const String databaseUnitTitle = 'unit_title';
  static const String databaseNewWords = 'new_words';
  static const String databaseExtraWords = 'extra_words';
  static const String databaseContent = 'unit_content';

  static Future<Database> initDatabase() async =>
    database ??= await openDatabase(
      join(await getDatabasesPath(), 'all.sqlite'),
      version: 1,
    );

  static Future<void> addWordsInUnit(Unit unit) async {
    final Database db = await getDBConnect();
    await db.insert(
      tableName,
      unit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> getTotalWordCount({required String inputPublisher, required int inputGrade, required String inputSemester}) async {
    final Database db = await getDBConnect();
    int count = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM $tableName WHERE $databaseGrade = '$inputGrade' AND $databaseSemester = '$inputSemester' "))!;
    return count;
  }

  static Future<int> getLearnedWordCount({required String inputAccount, required String inputPublisher, required int inputGrade, required String inputSemester}) async {
    List<Unit> units = await getUnits(
      inputGrade: inputGrade, 
      inputPublisher: inputPublisher, 
      inputSemester: inputSemester
    );
    int count = 0;
    for (var unit in units){
      List<WordStatus> wordStatuses = await WordStatusProvider.getWordsStatus(
        words: List.from(unit.newWords)..addAll(unit.extraWords),
        account:inputAccount
      );
      for (var status in wordStatuses){
        count += status.learned ? 1 : 0 ;
      }
    }
    return count;
  }
    
  static Future<List<Unit>> getUnits({required String inputPublisher, required int inputGrade, required String inputSemester}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: [databaseId, databaseUnitId, databaseUnitTitle, databaseNewWords, databaseExtraWords],
      where: "$databasePublisher = ? and $databaseGrade = ? and $databaseSemester = ?",
      whereArgs: [inputPublisher, inputGrade, inputSemester]
    );
    return List.generate(maps.length, (i) {
      return Unit(
        id: maps[i][databaseId],
        publisher: inputPublisher,
        grade: inputGrade,
        semester: inputSemester,
        unitId: maps[i][databaseUnitId],
        unitTitle: maps[i][databaseUnitTitle],
        newWords: maps[i][databaseNewWords].split(''),
        extraWords: maps[i][databaseExtraWords].split(''),
        unitContent: "",
      );
    });
  }

  static void closeDb() async {
    database = null;
    await deleteDatabase(
      join(await getDatabasesPath(), 'all.sqlite')
    );
  }
}
