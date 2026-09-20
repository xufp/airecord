import 'package:airecordapp/constant/CommonConstants.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:floor/floor.dart';

@dao
abstract class RecordingDao {
  // 查询并返回所有的 Recording 实体对象列表
  @Query('SELECT * FROM recording where user_id = :userId')
  Future<List<Recording>> findAllRecordings(String userId);

  // 根据提供的 id 查询并返回匹配的 Recording 实体对象
  // 这是一个异步数据流，当数据发生变化时，会自动更新
  @Query('SELECT * FROM recording WHERE id = :id limit 1')
  Future<Recording?> findRecordingById(int id);

  // 根据fileName查询并返回匹配的Recording实体对象
  @Query(
      "SELECT * FROM recording WHERE user_id = :userId and file_name = :fileName LIMIT 1")
  Future<Recording?> findRecordingByFileName(String userId, String fileName);

  // 将提供的 Recording 对象插入到数据库中
  // 这是一个异步操作，不返回任何数据
  @insert
  Future<void> insertRecording(Recording recording);

  // 更新media_id字段的方法
  @Query(
      'UPDATE recording SET media_id = :mediaId, updated_at = :updatedAt WHERE id = :id')
  Future<void> updateMediaId(int id, int mediaId, int updatedAt);

  @Query(
      'UPDATE recording SET is_upload = :status, updated_at = :updatedAt WHERE id = :id')
  Future<void> updateUploadStatus(int id, int status, int updatedAt);

  // 更新trans_text字段的方法
  @Query(
      'UPDATE recording SET is_translated = :isTranslated, trans_text = :transText, updated_at = :updatedAt WHERE id = :id')
  Future<void> updateTransText(
      int id, int isTranslated, String transText, int updatedAt);

  // 更新summary_text字段的方法
  @Query(
      'UPDATE recording SET is_summary = :isSummary, summary_text = :summaryText, updated_at = :updatedAt WHERE id = :id')
  Future<void> updateSummaryText(
      int id,
      int isSummary,
      String summaryText,
      int updatedAt,
      );

  @Query(
      'SELECT * FROM recording where user_id = :userId ORDER BY updated_at DESC LIMIT :limit OFFSET :offset')
  Future<List<Recording>> findRecordingsByPage(String userId, int limit, int offset);

  @Query(
      'SELECT * FROM recording where user_id = :userId ORDER BY updated_at DESC LIMIT :limit OFFSET :offset')
  Future<List<Recording>> sortRecordingsByPage(
      String userId, int limit, int offset);

  @Query(
      'SELECT * FROM recording WHERE user_id = :userId and file_name LIKE :text ORDER BY updated_at DESC LIMIT :limit OFFSET :offset')
  Future<List<Recording>> searchRecordingsByPage(
      String userId, String text, int limit, int offset);

  @Query(
      'SELECT * FROM recording WHERE user_id = :userId and is_translated = :isTranslated ORDER BY updated_at DESC LIMIT :limit OFFSET :offset')
  Future<List<Recording>> filterRecordingsByPage(
      String userId, String isTranslated, int limit, int offset);

  // 删除音频记录
  @delete
  Future<void> deleteRecording(Recording recording);

  // 扫描查询未同步到云服务的录音笔音频
  @Query(
      'delete FROM recording WHERE id > :id')
  Future<void> deleteAll(int id);

  // 扫描查询未同步到云服务的录音笔音频
  @Query(
      'SELECT * FROM recording WHERE user_id = :userId and source = :source AND media_id = ${CommonConstants.DEFAULT_MEDIA_ID}  AND is_delete = ${CommonConstants.NOT_DELETED} ORDER BY id ASC,upload_count ASC LIMIT :limit OFFSET :offset')
  Future<List<Recording>> findRecordingsNotUploadByPage(
      String userId, String source, int limit, int offset);

  // 文件上传失败更新
  @Query(
      'UPDATE recording SET upload_count = :uploadCount, updated_at = :updatedAt WHERE id = :id')
  Future<void> updateUploadCount(int id, int uploadCount, int updatedAt);

  // 根据fileName查询并返回匹配的Recording实体对象
  @Query(
      "SELECT * FROM recording WHERE media_id = :mediaId AND is_delete = ${CommonConstants.NOT_DELETED} LIMIT 1")
  Future<Recording?> findRecordingByMediaId(int mediaId);

  // 文件名称修改
  @Query(
      'UPDATE recording SET file_name = :fileName, updated_at = :updatedAt WHERE id = :id')
  Future<void> updateFileName(int id, String fileName, int updatedAt);
}
