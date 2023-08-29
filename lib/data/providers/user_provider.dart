import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/user_model.dart';

class UserProvider {
  static Database? database;
  static Future<Database> getDBConnect() async {
    database ??= await initDatabase();
    return database!;
  }

  static String tableName = 'users';
  
  // Define constants for database
  static const String databaseAccount = 'account';
  static const String databasePassword = 'password';
  static const String databaseUserName = 'username';


  static Future<Database> initDatabase() async =>
    database ??= await openDatabase(
      join(await getDatabasesPath(), 'users.sqlite'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $tableName($databaseAccount TEXT PRIMARY KEY, $databasePassword TEXT, $databaseUserName TEXT)",
        );
      },
      version: 1,
    );

  static Future<void> addUser({required User user}) async {
    final Database db = await getDBConnect();
    await db.insert(
      tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
    
  static Future<User> getUser({required String inputAccount}) async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: [databaseAccount, databasePassword, databaseUserName],
      where: " $databaseAccount = ? ",
      whereArgs: [inputAccount]
    );
    return User(
      account: maps[0][databaseAccount],
      password: maps[0][databasePassword],
      username: maps[0][databaseUserName],
    );
  }

  static Future<List<User>> getAllUser() async {
    final Database db = await getDBConnect();
    final List<Map<String, dynamic>> maps = await db.query(tableName,
      columns: [databaseAccount, databasePassword, databaseUserName],
    );
    return List.generate(maps.length, (i) {
      return User(
        account: maps[i][databaseAccount],
        password: maps[i][databasePassword],
        username: maps[i][databaseUserName],
      );
    });
  }

  static Future<void> updateUser({required User user}) async {
    final Database db = await getDBConnect();
    await db.update(
      tableName,
      user.toMap(),
      where: " $databaseAccount = ? ",
      whereArgs: [user.account]
    );
  }

  static Future<void> deleteUser({required String inputAccount}) async {
    final Database db = await getDBConnect();
    await db.delete(tableName,
      where: " $databaseAccount = ? ",
      whereArgs: [inputAccount]
    );
  }

  static void closeDb(){
    database!.close();
  }
}
