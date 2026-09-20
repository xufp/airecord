import 'package:airecordapp/constant/CommonConstants.dart';
import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/db/Db.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/enum/RecordSourceEnum.dart';
import 'package:airecordapp/util/DateUtil.dart';
import 'package:flutter_udid/flutter_udid.dart';

class RecordingService {
  get table async {
    // 使用数据库生成器创建数据库实例，传递数据库文件的名称（'app_database.db'）
    final database = await Db.db;
    // 从数据库实例中获取 RecordingDao 实例
    final recordingDao = database.recordingDao;
    return recordingDao;
  }

  Future<void> insert(int timeLong, String fileName, String originalFileName,
      String filePath, String source) async {
    String uuid = await FlutterUdid.udid;
    String title = DateUtil.nowYmdCn;
    int time = DateTime.now().millisecondsSinceEpoch;
    int isTranslated = 0;
    int mediaId = 0;
    String mediaName = '';
    String transText = '';
    String deviceId = '';
    String address = '';
    String tag = '';
    String userId = await Cache.userId;
    int isSummary = 0;
    String summaryText = '';
    int isUpload = CommonConstants.NOT_UPLOADED;

    // 创建一个 Recording 对象
    final recording = Recording(
        null,
        uuid,
        title,
        fileName,
        originalFileName,
        filePath,
        timeLong,
        isTranslated,
        mediaId,
        mediaName,
        transText,
        deviceId,
        address,
        source,
        tag,
        time,
        time,
        userId,
        isSummary,
        summaryText,
        isUpload,
        CommonConstants.UPLOAD_DEFAULT_COUNT,
        CommonConstants.NOT_DELETED);
    // 将新的 Recording 对象插入到数据库中
    (await table).insertRecording(recording);
  }

  Future<void> insertTrans(
      {required int timeLong,
      required String fileName,
      required String originalFileName,
      required String filePath,
      required int mediaId,
      required String mediaName,
      required String transText,
      required int isTranslated,
      required String source,
      int isUpload = CommonConstants.NOT_UPLOADED}) async {
    String uuid = await FlutterUdid.udid;
    String title = DateUtil.nowYmdCn;
    int time = DateTime.now().millisecondsSinceEpoch;
    String deviceId = '';
    String address = '';
    String tag = '';
    String userId = await Cache.userId;
    int isSummary = 0;
    String summaryText = '';
    // 创建一个 Recording 对象
    final recording = Recording(
        null,
        uuid,
        title,
        fileName,
        originalFileName,
        filePath,
        timeLong,
        isTranslated,
        mediaId,
        mediaName,
        transText,
        deviceId,
        address,
        source,
        tag,
        time,
        time,
        userId,
        isSummary,
        summaryText,
        isUpload,
        CommonConstants.UPLOAD_DEFAULT_COUNT,
        CommonConstants.NOT_DELETED);
    // 将新的 Recording 对象插入到数据库中
    (await table).insertRecording(recording);
  }

  Future<Recording?> getResultById(int id) async {
    return (await table).findRecordingById(id);
  }

  Future<void> updateMediaId(int id, int mediaId) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    (await table).updateMediaId(id, mediaId, time);
  }

  Future<void> updateTransText(int id, int state, String transContent) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    (await table).updateTransText(id, state, transContent, time);
  }

  Future<void> updateUploadStatus(int id, int state) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    (await table).updateUploadStatus(id, state, time);
  }

  Future<void> updateSummaryText(
      int id, int state, String summaryContent) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    (await table).updateSummaryText(id, state, summaryContent, time);
  }

  Future<List<Recording>> findRecordingsByPage(int limit, int offset) async {
    String userId = await Cache.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('userId is null');
    }
    return (await table).findRecordingsByPage(userId, limit, offset);
  }

  Future<List<Recording>> sortRecordingsByPage(
      int limit, int offset, String sortColumn) async {
    String userId = await Cache.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('userId is null');
    }
    return (await table).sortRecordingsByPage(userId, limit, offset);
  }

  Future<List<Recording>> filterRecordingsByPage(
      String isTranslated, String sortColumn, int limit, int offset) async {
    String userId = await Cache.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('userId is null');
    }
    return (await table)
        .filterRecordingsByPage(userId, isTranslated, limit, offset);
  }

  Future<List<Recording>> searchRecordingsByPage(
      String text, int limit, int offset) async {
    String userId = await Cache.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('userId is null');
    }
    return (await table).searchRecordingsByPage(userId, '%$text%', limit, offset);
  }

  Future<void> delete(Recording record) async {
    (await table).deleteRecording(record);
  }

  Future<Recording?> getRecordingByFileName(String fileName) async {
    String userId = await Cache.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('userId is null');
    }
    return (await table).findRecordingByFileName(userId, fileName);
  }

  Future<List<Recording>> findAllRecordings() async {
    String userId = await Cache.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('userId is null');
    }
    return (await table).findAllRecordings(userId);
  }

  Future<void> insertRecording(Recording recording) async {
    (await table).insertRecording(recording);
  }

  Future<void> updateFileName(int id, String fileName) async {
    //更新本地数据库名称
    int time = DateTime.now().millisecondsSinceEpoch;
    (await table).updateFileName(id, fileName, time);
  }

  Future<void> deleteAll() async {
    (await table).deleteAll(0);
  }

  Future<void> deleteRecording(Recording recording) async {
    (await table).deleteRecording(recording);
  }

  Future<List<Recording>> findPenRecordingsNotUploadByPage(
      int limit, int offset) async {
    String userId = await Cache.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('userId is null');
    }
    return (await table).findRecordingsNotUploadByPage(userId,
        RecordSourceEnum.PEN.source, limit, offset);
  }

  Future<void> updateUploadCount(int id, int uploadCount) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    return (await table).updateUploadCount(id, uploadCount, time);
  }

  Future<Recording?> getRecordingByMediaId(int mediaId) async {
    return (await table).findRecordingByMediaId(mediaId);
  }
}
