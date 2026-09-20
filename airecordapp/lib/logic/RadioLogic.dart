import 'dart:convert';

import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/enum/EngineTypeEnum.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/RecordingService.dart';
import 'package:airecordapp/service/request/MediaConvertRequest.dart';
import 'package:airecordapp/service/request/MediaRemoveRequest.dart';
import 'package:airecordapp/service/request/MediaSummaryRequest.dart';
import 'package:airecordapp/service/response/MediaConvertResponse.dart';
import 'package:airecordapp/service/response/MediaRemoveResponse.dart';
import 'package:airecordapp/service/response/MediaResponse.dart';
import 'package:airecordapp/service/response/MediaSummaryResponse.dart';
import 'package:airecordapp/util/AudioUtil.dart';
import 'package:airecordapp/util/LogUtil.dart';

class RadioLogic {
  RecordingService _recordingService = RecordingService();
  final logger = LogUtil.inItLog();

  /**
   * 录音转写
   */
  Future<MediaConvertResponse> mediaConvert(
      {required int mediaId, String? engineType}) async {
    if (engineType == null) {
      engineType = EngineTypeEnum.ZH.type;
    }
    try {
      MediaConvertRequest req =
          MediaConvertRequest(mediaId: mediaId, engineType: engineType);
      final resp = await DioService.mediaConvert(req);
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        return resp;
      }
    } catch (e) {
      logger.e('转写内容异常:$e');
    }
    return MediaConvertResponse(
        code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
  }

  /**
   * socket边录音边转写
   */
  MediaResponse media(String message) {
    try {
      Map<String, dynamic> jsonMap = jsonDecode(message);
      MediaResponse response = MediaResponse.fromJson(jsonMap);
      if (response.code == ErrConstants.SUCCESS_SOCKET_CODE) {
        return response;
      }
    } catch (e) {
      logger.e('边录边转写内容异常:$e');
    }
    return MediaResponse(
        code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
  }

  Future<MediaRemoveResponse> mediaRemove(int mediaId) async {
    try {
      MediaRemoveRequest req = MediaRemoveRequest(mediaId);
      final resp = await DioService.mediaRemove(req);
      if (resp.code == ErrConstants.SUCCESS_CODE) {
        return resp;
      }
    } catch (e) {
      logger.e('音频删除异常:$e');
    }

    return MediaRemoveResponse(
        code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
  }

  /**
   * 批量删除音频
   */
  Future<bool> batchMediaRemove(List<Recording> recordList) async {
    if (recordList.isEmpty) {
      return true;
    }
    for (Recording recording in recordList) {
      MediaRemoveRequest req = MediaRemoveRequest(recording.mediaId);
      try {
        if (recording.mediaId != null && recording.mediaId != 0) {
          final resp = await DioService.mediaRemove(req);
          logger.d('删除音频:${jsonEncode(resp.toJson())}');
          if (resp.code != ErrConstants.SUCCESS_CODE) {
            return false;
          }
        }
        // 删除本地音频文件
        await AudioUtil.deleteAudioFile(recording.filePath);
        // 删除数据库内音频文件
        await _recordingService.delete(recording);
      } catch (e) {
        logger.e('音频删除异常:$e');
        return false;
      }
    }
    return true;
  }

  /**
   * 音频总结
   */
  Future<MediaSummaryResponse> mediaSummary(int mediaId, String promptId) async {
    try {
      MediaSummaryRequest req = MediaSummaryRequest(mediaId: mediaId, promptId: promptId);
      final resp = await DioService.mediaSummary(req);
      return resp;
    } catch (e) {
      logger.e('总结内容异常:$e');
    }
    return MediaSummaryResponse(
        code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
  }
}
