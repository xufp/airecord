// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RecordingDao? _recordingDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 11,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `recording` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `uuid` TEXT NOT NULL, `title` TEXT NOT NULL, `file_name` TEXT NOT NULL, `original_file_name` TEXT NOT NULL, `file_path` TEXT NOT NULL, `time_long` INTEGER NOT NULL, `is_translated` INTEGER NOT NULL, `media_id` INTEGER NOT NULL, `media_name` TEXT NOT NULL, `trans_text` TEXT NOT NULL, `device_id` TEXT NOT NULL, `address` TEXT NOT NULL, `source` TEXT NOT NULL, `tag` TEXT NOT NULL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, `user_id` TEXT NOT NULL, `is_summary` INTEGER NOT NULL, `summary_text` TEXT NOT NULL, `is_upload` INTEGER NOT NULL, `upload_count` INTEGER NOT NULL, `is_delete` INTEGER NOT NULL)');
        await database.execute(
            'CREATE INDEX `index_recording_title` ON `recording` (`title`)');
        await database.execute(
            'CREATE INDEX `index_recording_file_name` ON `recording` (`file_name`)');
        await database.execute(
            'CREATE INDEX `index_recording_media_id` ON `recording` (`media_id`)');
        await database.execute(
            'CREATE INDEX `index_recording_source` ON `recording` (`source`)');
        await database.execute(
            'CREATE INDEX `index_recording_created_at` ON `recording` (`created_at`)');
        await database.execute(
            'CREATE INDEX `index_recording_updated_at` ON `recording` (`updated_at`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  RecordingDao get recordingDao {
    return _recordingDaoInstance ??= _$RecordingDao(database, changeListener);
  }
}

class _$RecordingDao extends RecordingDao {
  _$RecordingDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recordingInsertionAdapter = InsertionAdapter(
            database,
            'recording',
            (Recording item) => <String, Object?>{
                  'id': item.id,
                  'uuid': item.uuid,
                  'title': item.title,
                  'file_name': item.fileName,
                  'original_file_name': item.originalFileName,
                  'file_path': item.filePath,
                  'time_long': item.timeLong,
                  'is_translated': item.isTranslated,
                  'media_id': item.mediaId,
                  'media_name': item.mediaName,
                  'trans_text': item.transText,
                  'device_id': item.deviceId,
                  'address': item.address,
                  'source': item.source,
                  'tag': item.tag,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt,
                  'user_id': item.userId,
                  'is_summary': item.isSummary,
                  'summary_text': item.summaryText,
                  'is_upload': item.isUpload,
                  'upload_count': item.uploadCount,
                  'is_delete': item.isDelete
                }),
        _recordingDeletionAdapter = DeletionAdapter(
            database,
            'recording',
            ['id'],
            (Recording item) => <String, Object?>{
                  'id': item.id,
                  'uuid': item.uuid,
                  'title': item.title,
                  'file_name': item.fileName,
                  'original_file_name': item.originalFileName,
                  'file_path': item.filePath,
                  'time_long': item.timeLong,
                  'is_translated': item.isTranslated,
                  'media_id': item.mediaId,
                  'media_name': item.mediaName,
                  'trans_text': item.transText,
                  'device_id': item.deviceId,
                  'address': item.address,
                  'source': item.source,
                  'tag': item.tag,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt,
                  'user_id': item.userId,
                  'is_summary': item.isSummary,
                  'summary_text': item.summaryText,
                  'is_upload': item.isUpload,
                  'upload_count': item.uploadCount,
                  'is_delete': item.isDelete
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Recording> _recordingInsertionAdapter;

  final DeletionAdapter<Recording> _recordingDeletionAdapter;

  @override
  Future<List<Recording>> findAllRecordings(String userId) async {
    return _queryAdapter.queryList('SELECT * FROM recording where user_id = ?1',
        mapper: (Map<String, Object?> row) => Recording(
            row['id'] as int?,
            row['uuid'] as String,
            row['title'] as String,
            row['file_name'] as String,
            row['original_file_name'] as String,
            row['file_path'] as String,
            row['time_long'] as int,
            row['is_translated'] as int,
            row['media_id'] as int,
            row['media_name'] as String,
            row['trans_text'] as String,
            row['device_id'] as String,
            row['address'] as String,
            row['source'] as String,
            row['tag'] as String,
            row['created_at'] as int,
            row['updated_at'] as int,
            row['user_id'] as String,
            row['is_summary'] as int,
            row['summary_text'] as String,
            row['is_upload'] as int,
            row['upload_count'] as int,
            row['is_delete'] as int),
        arguments: [userId]);
  }

  @override
  Future<Recording?> findRecordingById(int id) async {
    return _queryAdapter.query('SELECT * FROM recording WHERE id = ?1 limit 1',
        mapper: (Map<String, Object?> row) => Recording(
            row['id'] as int?,
            row['uuid'] as String,
            row['title'] as String,
            row['file_name'] as String,
            row['original_file_name'] as String,
            row['file_path'] as String,
            row['time_long'] as int,
            row['is_translated'] as int,
            row['media_id'] as int,
            row['media_name'] as String,
            row['trans_text'] as String,
            row['device_id'] as String,
            row['address'] as String,
            row['source'] as String,
            row['tag'] as String,
            row['created_at'] as int,
            row['updated_at'] as int,
            row['user_id'] as String,
            row['is_summary'] as int,
            row['summary_text'] as String,
            row['is_upload'] as int,
            row['upload_count'] as int,
            row['is_delete'] as int),
        arguments: [id]);
  }

  @override
  Future<Recording?> findRecordingByFileName(
    String userId,
    String fileName,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM recording WHERE user_id = ?1 and file_name = ?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => Recording(
            row['id'] as int?,
            row['uuid'] as String,
            row['title'] as String,
            row['file_name'] as String,
            row['original_file_name'] as String,
            row['file_path'] as String,
            row['time_long'] as int,
            row['is_translated'] as int,
            row['media_id'] as int,
            row['media_name'] as String,
            row['trans_text'] as String,
            row['device_id'] as String,
            row['address'] as String,
            row['source'] as String,
            row['tag'] as String,
            row['created_at'] as int,
            row['updated_at'] as int,
            row['user_id'] as String,
            row['is_summary'] as int,
            row['summary_text'] as String,
            row['is_upload'] as int,
            row['upload_count'] as int,
            row['is_delete'] as int),
        arguments: [userId, fileName]);
  }

  @override
  Future<void> updateMediaId(
    int id,
    int mediaId,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE recording SET media_id = ?2, updated_at = ?3 WHERE id = ?1',
        arguments: [id, mediaId, updatedAt]);
  }

  @override
  Future<void> updateUploadStatus(
    int id,
    int status,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE recording SET is_upload = ?2, updated_at = ?3 WHERE id = ?1',
        arguments: [id, status, updatedAt]);
  }

  @override
  Future<void> updateTransText(
    int id,
    int isTranslated,
    String transText,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE recording SET is_translated = ?2, trans_text = ?3, updated_at = ?4 WHERE id = ?1',
        arguments: [id, isTranslated, transText, updatedAt]);
  }

  @override
  Future<void> updateSummaryText(
    int id,
    int isSummary,
    String summaryText,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE recording SET is_summary = ?2, summary_text = ?3, updated_at = ?4 WHERE id = ?1',
        arguments: [id, isSummary, summaryText, updatedAt]);
  }

  @override
  Future<List<Recording>> findRecordingsByPage(
    String userId,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM recording where user_id = ?1 ORDER BY updated_at DESC LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => Recording(row['id'] as int?, row['uuid'] as String, row['title'] as String, row['file_name'] as String, row['original_file_name'] as String, row['file_path'] as String, row['time_long'] as int, row['is_translated'] as int, row['media_id'] as int, row['media_name'] as String, row['trans_text'] as String, row['device_id'] as String, row['address'] as String, row['source'] as String, row['tag'] as String, row['created_at'] as int, row['updated_at'] as int, row['user_id'] as String, row['is_summary'] as int, row['summary_text'] as String, row['is_upload'] as int, row['upload_count'] as int, row['is_delete'] as int),
        arguments: [userId, limit, offset]);
  }

  @override
  Future<List<Recording>> sortRecordingsByPage(
    String userId,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM recording where user_id = ?1 ORDER BY updated_at DESC LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => Recording(row['id'] as int?, row['uuid'] as String, row['title'] as String, row['file_name'] as String, row['original_file_name'] as String, row['file_path'] as String, row['time_long'] as int, row['is_translated'] as int, row['media_id'] as int, row['media_name'] as String, row['trans_text'] as String, row['device_id'] as String, row['address'] as String, row['source'] as String, row['tag'] as String, row['created_at'] as int, row['updated_at'] as int, row['user_id'] as String, row['is_summary'] as int, row['summary_text'] as String, row['is_upload'] as int, row['upload_count'] as int, row['is_delete'] as int),
        arguments: [userId, limit, offset]);
  }

  @override
  Future<List<Recording>> searchRecordingsByPage(
    String userId,
    String text,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM recording WHERE user_id = ?1 and file_name LIKE ?2 ORDER BY updated_at DESC LIMIT ?3 OFFSET ?4',
        mapper: (Map<String, Object?> row) => Recording(row['id'] as int?, row['uuid'] as String, row['title'] as String, row['file_name'] as String, row['original_file_name'] as String, row['file_path'] as String, row['time_long'] as int, row['is_translated'] as int, row['media_id'] as int, row['media_name'] as String, row['trans_text'] as String, row['device_id'] as String, row['address'] as String, row['source'] as String, row['tag'] as String, row['created_at'] as int, row['updated_at'] as int, row['user_id'] as String, row['is_summary'] as int, row['summary_text'] as String, row['is_upload'] as int, row['upload_count'] as int, row['is_delete'] as int),
        arguments: [userId, text, limit, offset]);
  }

  @override
  Future<List<Recording>> filterRecordingsByPage(
    String userId,
    String isTranslated,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM recording WHERE user_id = ?1 and is_translated = ?2 ORDER BY updated_at DESC LIMIT ?3 OFFSET ?4',
        mapper: (Map<String, Object?> row) => Recording(row['id'] as int?, row['uuid'] as String, row['title'] as String, row['file_name'] as String, row['original_file_name'] as String, row['file_path'] as String, row['time_long'] as int, row['is_translated'] as int, row['media_id'] as int, row['media_name'] as String, row['trans_text'] as String, row['device_id'] as String, row['address'] as String, row['source'] as String, row['tag'] as String, row['created_at'] as int, row['updated_at'] as int, row['user_id'] as String, row['is_summary'] as int, row['summary_text'] as String, row['is_upload'] as int, row['upload_count'] as int, row['is_delete'] as int),
        arguments: [userId, isTranslated, limit, offset]);
  }

  @override
  Future<void> deleteAll(int id) async {
    await _queryAdapter
        .queryNoReturn('delete FROM recording WHERE id > ?1', arguments: [id]);
  }

  @override
  Future<List<Recording>> findRecordingsNotUploadByPage(
    String userId,
    String source,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM recording WHERE user_id = ?1 and source = ?2 AND media_id = 0  AND is_delete = 0 ORDER BY id ASC,upload_count ASC LIMIT ?3 OFFSET ?4',
        mapper: (Map<String, Object?> row) => Recording(row['id'] as int?, row['uuid'] as String, row['title'] as String, row['file_name'] as String, row['original_file_name'] as String, row['file_path'] as String, row['time_long'] as int, row['is_translated'] as int, row['media_id'] as int, row['media_name'] as String, row['trans_text'] as String, row['device_id'] as String, row['address'] as String, row['source'] as String, row['tag'] as String, row['created_at'] as int, row['updated_at'] as int, row['user_id'] as String, row['is_summary'] as int, row['summary_text'] as String, row['is_upload'] as int, row['upload_count'] as int, row['is_delete'] as int),
        arguments: [userId, source, limit, offset]);
  }

  @override
  Future<void> updateUploadCount(
    int id,
    int uploadCount,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE recording SET upload_count = ?2, updated_at = ?3 WHERE id = ?1',
        arguments: [id, uploadCount, updatedAt]);
  }

  @override
  Future<Recording?> findRecordingByMediaId(int mediaId) async {
    return _queryAdapter.query(
        'SELECT * FROM recording WHERE media_id = ?1 AND is_delete = 0 LIMIT 1',
        mapper: (Map<String, Object?> row) => Recording(
            row['id'] as int?,
            row['uuid'] as String,
            row['title'] as String,
            row['file_name'] as String,
            row['original_file_name'] as String,
            row['file_path'] as String,
            row['time_long'] as int,
            row['is_translated'] as int,
            row['media_id'] as int,
            row['media_name'] as String,
            row['trans_text'] as String,
            row['device_id'] as String,
            row['address'] as String,
            row['source'] as String,
            row['tag'] as String,
            row['created_at'] as int,
            row['updated_at'] as int,
            row['user_id'] as String,
            row['is_summary'] as int,
            row['summary_text'] as String,
            row['is_upload'] as int,
            row['upload_count'] as int,
            row['is_delete'] as int),
        arguments: [mediaId]);
  }

  @override
  Future<void> updateFileName(
    int id,
    String fileName,
    int updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE recording SET file_name = ?2, updated_at = ?3 WHERE id = ?1',
        arguments: [id, fileName, updatedAt]);
  }

  @override
  Future<void> insertRecording(Recording recording) async {
    await _recordingInsertionAdapter.insert(
        recording, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRecording(Recording recording) async {
    await _recordingDeletionAdapter.delete(recording);
  }
}

// ignore_for_file: unused_element
final _nullStringConverter = NullStringConverter();
