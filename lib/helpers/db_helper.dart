import "package:sqflite/sqflite.dart" as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';

class DbHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'user_transactions.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_transactions(id TEXT PRIMARY KEY,title TEXT,amount REAL,date TEXT)');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await DbHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String,dynamic>>> getData(String table) async {
    final db = await DbHelper.database();
    return db.query(table);
  }
  static Future<void> delete(String table, String id) async {
    final db = await DbHelper.database();
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
