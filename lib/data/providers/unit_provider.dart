import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/all_provider.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/unit_model.dart';

class UnitProvider {
  Database? _database;

  // Singleton pattern for UnitProvider
  static final UnitProvider _instance = UnitProvider._internal();

  factory UnitProvider() {
    return _instance;
  }

  UnitProvider._internal();

  static const String tableName = "TextBooks";
  
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

  /// Fetch the singleton instance of the database, checking if it is closed
  Future<Database> get database async {
    if (AllProvider.isDbClosed) {
      throw Exception('Database is closed and cannot be accessed.');
    }
    _database ??= await AllProvider().database;
    return _database!;
  }

  /// Adds words in the unit to the database
  Future<void> addWordsInUnit(Unit unit) async {
    final Database db = await database;
    await db.insert(
      tableName,
      unit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetches total word count for the given publisher, grade, and semester
  Future<int> getTotalWordCount({required String inputPublisher, required int inputGrade, required String inputSemester}) async {
    final Database db = await database;
    List<Map<String, Object?>> unitWords = await db.query(
      tableName,
      columns: [databaseNewWords, databaseExtraWords],
      where: '$databaseGrade = ? and $databaseSemester = ? and $databasePublisher = ?',
      whereArgs: [inputGrade, inputSemester, inputPublisher]
    );
    int count = 0;
    for (var unit in unitWords) {
      count += unit[databaseNewWords]?.toString().length ?? 0;
      count += unit[databaseExtraWords]?.toString().length ?? 0;
    }
    return count;
  }

  /// Fetches learned word count for the given account, publisher, grade, and semester
  Future<int> getLearnedWordCount({required String inputAccount, required String inputPublisher, required int inputGrade, required String inputSemester}) async {
    List<Unit> units = await getUnits(
      inputGrade: inputGrade, 
      inputPublisher: inputPublisher, 
      inputSemester: inputSemester
    );
    int count = 0;

    for (var unit in units) {
      try {
        List<WordStatus> wordStatuses = await WordStatusProvider().getWordsStatus(
          words: List.from(unit.newWords)..addAll(unit.extraWords),
          account: inputAccount
        );
        for (var status in wordStatuses) {
          count += status.learned ? 1 : 0;
        }
      } catch (e) {
        debugPrint('Unit ${unit.unitId} hasn\'t been read before');
      }
    }
    return count;
  }
    
  /// Fetches units for the given publisher, grade, and semester
  Future<List<Unit>> getUnits({required String inputPublisher, required int inputGrade, required String inputSemester}) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
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

  // Nothing to close in this provider, so no need for dispose
  
}
