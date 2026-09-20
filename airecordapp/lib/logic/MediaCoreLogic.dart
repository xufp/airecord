import 'dart:convert';

import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/enum/MediaStateEnum.dart';
import 'package:airecordapp/logic/MediaSummaryLogic.dart';
import 'package:airecordapp/logic/MediaTransferLogic.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/RecordingService.dart';
import 'package:airecordapp/service/request/MediaConvertResetRequest.dart';
import 'package:airecordapp/service/request/MediaConvertStatusRequest.dart';
import 'package:airecordapp/service/request/MediaSummaryStatusRequest.dart';
import 'package:airecordapp/service/response/MediaConvertResetResponse.dart';
import 'package:airecordapp/service/response/MediaConvertStatusResponse.dart';
import 'package:airecordapp/service/response/MediaResponse.dart';
import 'package:airecordapp/service/response/MediaSummaryStatusResponse.dart';

/**
 * 核心的音频操作逻辑
 * 1. 音频文件上传 （支持幂等）
 * 2. 音频内容转写（支持幂等）
 * 3. 音频内容总结（支持幂等）
 */
class MediaCoreLogic  {

  final Recording _recording;

  RecordingService _recordingService = RecordingService();

  final String promptId;
  final String enginType;

  MediaCoreLogic(this._recording, this.promptId, this.enginType);

  Future<String> upload() async {
    int code = await MediaTransfer(_recording, enginType)
        .mediaUpload(transferCallback: transferCallback);
    return code.toString();
  }


  // 转写重置
  Future<MediaConvertResetResponse> reset() async {
    Recording? _recordingTmp = await _recordingService.getResultById(_recording.id!);
    if(_recordingTmp != null && _recordingTmp.mediaId != null && _recordingTmp.mediaId != 0) {
      MediaConvertResetRequest request = MediaConvertResetRequest(mediaId: _recordingTmp.mediaId);
      //返回上传的状态
      MediaConvertResetResponse response = await DioService.resetConvertRecord(request);
      return response;
    }
    return MediaConvertResetResponse(code: ErrConstants.SUCCESS_CODE, msg: "success");
  }

  /**
   * 获取状态用于
   * 1. 判断页面是显示转写中，还是显示转写按钮
   * 2. 拉取转写结果，更新到DB和页面
   */
  Future<MediaResponse> getStatus() async{
    //根据_recording.id从DB中获取mediaId
    Recording? _recordingTmp = await _recordingService.getResultById(_recording.id!);
    if(_recordingTmp == null) {
      print('[DEBUG] getStatus: 录音文件不存在, id=${_recording.id}');
      return MediaResponse(code: ErrConstants.MEDIA_NOT_FOUND_CODE, msg: "录音文件不存在");
    }
    print('[DEBUG] getStatus: recording.id=${_recordingTmp.id}, mediaId=${_recordingTmp.mediaId}, isTranslated=${_recordingTmp.isTranslated}, isSummary=${_recordingTmp.isSummary}');
    if(_recordingTmp.mediaId == null || _recordingTmp.mediaId == 0)  {
      print('[DEBUG] getStatus: mediaId为空或0，返回MEDIA_NOT_UPLOAD_CODE');
      return MediaResponse(code: ErrConstants.MEDIA_NOT_UPLOAD_CODE, msg: "音频文件未上传");
    }
    if(_recordingTmp.isSummary == MediaStateEnum.SUMMARYED.state)   {
      print('[DEBUG] getStatus: 已摘要，返回MEDIA_IS_SUMMARY_CODE');
      return MediaResponse(code: ErrConstants.MEDIA_IS_SUMMARY_CODE, msg: "音频文件已摘要");
    }
    if(_recordingTmp.isTranslated == 0)   {
      print('[DEBUG] getStatus: 未转写, 查询转写状态, mediaId=${_recordingTmp.mediaId}');
      MediaConvertStatusRequest request = MediaConvertStatusRequest(mediaId: _recordingTmp.mediaId, detail: true);
      MediaConvertStatusResponse response =
      await DioService.mediaConvertStatus(request);
      print('[DEBUG] getStatus: 转写状态查询结果 code=${response.code}, state=${response.state}');
      if(response.code == ErrConstants.MEDIA_TRANSFER_NOT_FOUND_CODE) {
        //转写记录不存在，重新转写
        print('[DEBUG] getStatus: 转写记录不存在');
        return MediaResponse(code: ErrConstants.MEDIA_NOT_TRANSFER_CODE, msg: "音频文件未转写");
      }
      if (response.code != ErrConstants.SUCCESS_CODE) {
        print('[DEBUG] getStatus: 转写状态查询失败 code=${response.code}');
        return MediaResponse(code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
      }
      if (response.state == 2) {
        // 转写成功
        print('[DEBUG] getStatus: 转写成功，写入DB');
        var transText = json.encode(response.sentenceDetailList);
        // 更新转写文案到数据库
        _recordingService.updateTransText(
            _recording.id!, MediaStateEnum.TRANSLATED.state, transText);
      } else if (response.state == 1 || response.state == 0)  {
        // 转写中
        print('[DEBUG] getStatus: 转写中 state=${response.state}');
        return MediaResponse(code: ErrConstants.MEDIA_TRANSFERING_CODE, msg: "音频文件转写中");
      } else {
        // 转写失败和未转写统一返回未转写
        print('[DEBUG] getStatus: 转写失败 state=${response.state}');
        return MediaResponse(code: ErrConstants.MEDIA_NOT_TRANSFER_CODE, msg: "音频文件未转写");
      }
    }

    if(_recordingTmp.isSummary == 0)   {
      MediaSummaryStatusRequest request =
      MediaSummaryStatusRequest(mediaId: _recordingTmp.mediaId ?? 0);
      MediaSummaryStatusResponse response =
      await DioService.mediaSummaryStatus(request);
      if(response.code == ErrConstants.MEDIA_SUMMARY_NOT_FOUND_CODE) {
        // 摘要失败和未摘要统一返回未摘要
        return MediaResponse(code: ErrConstants.MEDIA_NOT_TRANSFER_CODE, msg: "音频文件未转写");
      }
      if(response.code == ErrConstants.MEDIA_SUMMARY_TOO_SHORT_CODE) {
        String summaryText = response.msg ?? "Text is too short to summarize";
        // 更新总结文案到数据库
        _recordingService.updateSummaryText(
            _recording.id!, MediaStateEnum.SUMMARYED.state, summaryText);
        // 摘要失败和未摘要统一返回未摘要
        return MediaResponse(code: ErrConstants.MEDIA_IS_SUMMARY_CODE, msg: "音频文件已摘要");
      }
      if (response.code != ErrConstants.SUCCESS_CODE) {
        return MediaResponse(code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
      }
      if (response.state == 2) {
        var summaryText = response.content == null || response.content!.isEmpty
            ? ""
            : response.content!;
        // 更新总结文案到数据库
        _recordingService.updateSummaryText(
            _recording.id!, MediaStateEnum.SUMMARYED.state, summaryText);
      } else if (response.state == 1 || response.state == 0)  {
        // 摘要中
        return MediaResponse(code: ErrConstants.MEDIA_SUMMARYING_CODE, msg: "音频文件摘要中");
      } else {
        // 摘要失败和未摘要统一返回未摘要
        return MediaResponse(code: ErrConstants.MEDIA_NOT_TRANSFER_CODE, msg: "音频文件未转写");
      }
    }
    return MediaResponse(code: ErrConstants.MEDIA_IS_SUMMARY_CODE, msg: "音频文件已摘要");
  }

  // 转写成功回调
  void transferCallback(int code, String msg, String text, int mediaId) {
    if (code == ErrConstants.SUCCESS_CODE) {
      //转写成功，执行摘要
      MediaSummary(_recording!, mediaId, promptId)
          .mediaSummary(summaryCallback: summaryCallback);
    }
  }

  // 摘要成功回调
  void summaryCallback(int code, String msg, String text) async {
  }
}