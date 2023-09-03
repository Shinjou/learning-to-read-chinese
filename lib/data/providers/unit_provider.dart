import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/unit_model.dart';

const Map<String, String> publisherName = {
  "南一": "nani",
  "康軒": "kang",
  "翰林": "hanlin"
};

class UnitProvider {
  static Database? database;
  static Future<Database> getDBConnect() async {
    String newPath = join(await getDatabasesPath(), 'units.sqlite');
    final exist = await databaseExists(newPath);
    if (!exist) {
      try {
        ByteData data =
            await rootBundle.load(join("assets/data_files", "units.sqlite"));
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(newPath).writeAsBytes(bytes, flush: true);
      } catch (e) {
        debugPrint('Failed to write bytes to the file at $newPath. Error: $e');
        throw Exception('Failed to write bytes to the file. Error: $e');
      }
    }
    database ??= await initDatabase();
    return database!;
  }

  static const String publisher = '康軒';
  static String tableName = publisherName[publisher]!;

  // Define constants for database
  static const String databasePublisher = 'publisher';
  static const String databaseGrade = 'grade';
  static const String databaseSemester = 'semester';
  static const String databaseUnitId = 'unit_id';
  static const String databaseUnitTitle = 'unit_title';
  static const String databaseNewWords = 'new_words';
  static const String databaseExtraWords = 'extra_words';

  static Future<Database> initDatabase() async =>
      database ??= await openDatabase(
        join(await getDatabasesPath(), 'units.sqlite'),
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

  static Future<List<Unit>> getUnits(
      {required int inputGrade, required String inputSemester}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        columns: [
          databaseGrade,
          databaseSemester,
          databaseUnitId,
          databaseUnitTitle,
          databaseNewWords,
          databaseExtraWords
        ],
        where: " $databaseGrade = ? and $databaseSemester = ? ",
        whereArgs: [inputGrade, inputSemester]);
    return List.generate(maps.length, (i) {
      debugPrint(maps.toString());
      return Unit(
        publisher: publisher,
        grade: maps[i][databaseGrade],
        semester: maps[i][databaseSemester],
        unitId: maps[i][databaseUnitId],
        unitTitle: maps[i][databaseUnitTitle],
        newWords: maps[i][databaseNewWords].split(''),
        extraWords: maps[i][databaseExtraWords].split(''),
      );
    });
  }

  static Future<List<Unit>> getWordsInUnit(
      int inputGrade, String inputSemester, int unitId) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        columns: [
          databaseGrade,
          databaseSemester,
          databaseUnitId,
          databaseUnitTitle,
          databaseNewWords,
          databaseExtraWords
        ],
        where:
            " $databaseGrade = ? and $databaseSemester = ? and $databaseUnitId = ?",
        whereArgs: [inputGrade, inputSemester, unitId]);
    return List.generate(maps.length, (i) {
      return Unit(
        publisher: maps[i][databasePublisher],
        grade: maps[i][databaseGrade],
        semester: maps[i][databaseSemester],
        unitId: maps[i][databaseUnitId],
        unitTitle: maps[i][databaseUnitTitle],
        newWords: maps[i][databaseNewWords].split(''),
        extraWords: maps[i][databaseExtraWords].split(''),
      );
    });
  }

  static void closeDb() {
    database!.close();
  }
}
