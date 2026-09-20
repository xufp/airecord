import 'package:airecordapp/db/database/AppDatabase.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  static Future<AppDatabase>? _db;

  static Future get db async {
    if (_db != null) {
      return _db;
    }
    _db = _initDb();
    return _db;
  }

  static Future<AppDatabase> _initDb() async {
    // 开发阶段直接删除旧数据库
    /*final dbPath = await getDatabasesPath();
    final path = '$dbPath/app_database.db';
    await deleteDatabase(path);*/

    final database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        //.addMigrations([migration9to10]) // 删除旧数据库
        .build();
    return database;
  }
}
