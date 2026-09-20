import 'package:floor/floor.dart';

@Entity(tableName: 'recording', indices: [
  Index(value: ['title']),
  Index(value: ['file_name']),
  Index(value: ['media_id']),
  Index(value: ['source']),
  Index(value: ['created_at']),
  Index(value: ['updated_at'])
])
class Recording {
  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: 'uuid')
  String uuid;

  @ColumnInfo(name: 'title')
  String title;

  @ColumnInfo(name: 'file_name')
  String fileName;

  @ColumnInfo(name: 'original_file_name')
  String originalFileName;

  @ColumnInfo(name: 'file_path')
  String filePath;

  @ColumnInfo(name: 'time_long')
  int timeLong;

  @ColumnInfo(name: 'is_translated')
  int isTranslated;

  @ColumnInfo(name: 'media_id')
  int mediaId;

  @ColumnInfo(name: 'media_name')
  String mediaName;

  @ColumnInfo(name: 'trans_text')
  String transText;

  @ColumnInfo(name: 'device_id')
  String deviceId;

  @ColumnInfo(name: 'address')
  String address;

  @ColumnInfo(name: 'source')
  String source;

  @ColumnInfo(name: 'tag')
  String tag;

  @ColumnInfo(name: 'created_at')
  int createdAt;

  @ColumnInfo(name: 'updated_at')
  int updatedAt;

  @ColumnInfo(name: 'user_id')
  String userId;

  @ColumnInfo(name: 'is_summary')
  int isSummary;

  @ColumnInfo(name: 'summary_text')
  String summaryText;

  @ColumnInfo(name: 'is_upload')
  int isUpload;

  @ColumnInfo(name: 'upload_count')
  int uploadCount;

  @ColumnInfo(name: 'is_delete')
  int isDelete;

  String toString() {
    return 'Recording(id: $id, uuid: $uuid, title: $title, fileName: $fileName, filePath: $filePath, timeLong: $timeLong, isTranslated: $isTranslated, mediaId: $mediaId, mediaName: $mediaName, transText: $transText, deviceId: $deviceId, address: $address, source: $source, tag: $tag, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, isSummary: $isSummary, summaryText: $summaryText, isUpload: $isUpload )';
  }

  Recording(
      this.id,
      this.uuid,
      this.title,
      this.fileName,
      this.originalFileName,
      this.filePath,
      this.timeLong,
      this.isTranslated,
      this.mediaId,
      this.mediaName,
      this.transText,
      this.deviceId,
      this.address,
      this.source,
      this.tag,
      this.createdAt,
      this.updatedAt,
      this.userId,
      this.isSummary,
      this.summaryText,
      this.isUpload,
      this.uploadCount,
      this.isDelete);
}
