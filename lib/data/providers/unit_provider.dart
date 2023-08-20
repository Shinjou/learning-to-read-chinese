import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/unit_model.dart';

class UnitProvider {
  static Database? database;
  static Future<Database> getDBConnect() async => database ??= await initDatabase();

  // Define constants for database
  static const String databaseYear = 'year';
  static const String databasePublisher = 'publisher';
  static const String databaseGrade = 'grade';
  static const String databaseSemester = 'semester';
  static const String databaseUnitId = 'unit_id';
  static const String databaseUnitTitle = 'unit_title';
  static const String databaseNewWords = 'new_words';
  static const String databaseExtraWords = 'extra_words';

  static Future<Database> initDatabase() async =>
    database ??= await openDatabase(
      join(await getDatabasesPath(), '../data_files/南一.sqlite'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE unit($databaseYear INTEGER, $databasePublisher TEXT, $databaseGrade INTEGER, $databaseSemester TEXT, $databaseUnitId INTEGER, $databaseUnitTitle TEXT, $databaseNewWords TEXT, $databaseExtraWords TEXT)",
        );
      },
      version: 1,
    );

  static Future<void> addWordsInUnit(Unit unit) async {
    final Database db = await getDBConnect();
    await db.insert(
      'unit',
      unit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
    
  static Future<List<Unit>> getUnits({required int inputGrade, required String inputSemester}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query('unit',
      columns: [databaseGrade, databaseSemester, databaseUnitId, databaseUnitTitle, databaseNewWords, databaseExtraWords],
      where: " $databaseGrade = ? and $databaseSemester = ? ",
      whereArgs: [inputGrade, inputSemester]
    );
    return List.generate(maps.length, (i) {
      return Unit(
        grade: maps[i][databaseGrade],
        semester: maps[i][databaseSemester],
        lessonId: maps[i][databaseUnitId],
        lessonTitle: maps[i][databaseUnitTitle],
        newWords: json.decode(maps[i][databaseNewWords]).cast<String>().toList(),
        extraWords: json.decode(maps[i][databaseExtraWords]).cast<String>().toList(),
      );
    });
  }

  static Future<List<Unit>> getWordsInUnit(int inputGrade, String inputSemester, int unitId) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query('unit',
      columns: [databaseGrade, databaseSemester, databaseUnitId, databaseUnitTitle, databaseNewWords, databaseExtraWords],
      where: " $databaseGrade = ? and $databaseSemester = ? and $databaseUnitId = ?",
      whereArgs: [inputGrade, inputSemester, unitId]
    );
    return List.generate(maps.length, (i) {
      return Unit(
        grade: maps[i][databaseGrade],
        semester: maps[i][databaseSemester],
        lessonId: maps[i][databaseUnitId],
        lessonTitle: maps[i][databaseUnitTitle],
        newWords: json.decode(maps[i][databaseNewWords]).cast<String>().toList(),
        extraWords: json.decode(maps[i][databaseExtraWords]).cast<String>().toList(),
      );
    });
  }
}
