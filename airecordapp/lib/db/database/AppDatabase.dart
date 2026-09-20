import 'dart:async';
import 'package:airecordapp/db/Cache.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../dao/RecordingDao.dart';
import '../entity/Recording.dart';

part 'AppDatabase.g.dart'; // Floor代码生成器将在这里生成相关的代码

/*final Migration migration9to10 = Migration(9, 10, (database) async {
  await database.execute(
      'ALTER TABLE recording ADD COLUMN source TEXT NOT NULL DEFAULT ""');
  await database.execute(
      'CREATE INDEX `index_recording_source` ON `recording` (`source`)');
});*/

@TypeConverters([NullStringConverter])
@Database(
  version: 11,
  entities: [Recording],
) // 声明数据库版本号和包含的实体类
abstract class AppDatabase extends FloorDatabase {
  RecordingDao get recordingDao; // RecordingDao获取RecordingDao实例，用于执行数据库操作
}

class NullStringConverter extends TypeConverter<String?, String> {
  @override
  String? decode(String databaseValue) {
    return databaseValue.isEmpty ? null : databaseValue;
  }

  @override
  String encode(String? value) {
    return value ?? '';
  }
}
