import 'dart:convert';

import 'package:airecordapp/constant/CommonConstants.dart';
import 'package:airecordapp/enum/RecordSourceEnum.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/enum/MediaStateEnum.dart';
import 'package:airecordapp/util/LogUtil.dart';
import '../../service/request/MediaSyncRequest.dart';
import '../../service/request/MediaUrlRequest.dart';
import '../../service/response/MediaSyncResponse.dart';
import '../../service/response/MediaUrlResponse.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../service/request/MediaConvertStatusRequest.dart';
import '../../service/response/MediaConvertStatusResponse.dart';
import '../service/RecordingService.dart';

class MediaSyncLogic {
  RecordingService recordingService = RecordingService();
  final logger = LogUtil.inItLog();

  Future<List<MediaInfo>> loadUnSyncMedia() async {
    // 获取远程音频列表
    int curPage = 1;
    List<MediaInfo> allMediaInfoList = [];
    while (true) {
      MediaSyncRequest req = MediaSyncRequest(page: curPage, size: 100);
      MediaSyncResponse response = await DioService.mediaSync(req);
      if (response.code != ErrConstants.SUCCESS_CODE) {
        return <MediaInfo>[];
      }
      allMediaInfoList.addAll(response.mediaInfoList);
      // 如果返回的数据不足当前页的大小，说明没有更多数据了
      if (response.mediaInfoList.length < response.size) {
        break;
      }

      curPage++;
    }

    // 获取本地音频列表
    List<Recording> localRecordingList =
        await recordingService.findAllRecordings();

    // 从远程音频列表中删除本地音频列表中已存在的项
    allMediaInfoList.removeWhere((mediaInfo) => localRecordingList
        .any((recording) => mediaInfo.mediaId == recording.mediaId));

    // 剔除无效音频
    allMediaInfoList.removeWhere(
        (mediaInfo) => mediaInfo.mediaType == 2 && mediaInfo.state == 4);

    return allMediaInfoList;
  }

  // 执行单个音频文件同步
  Future<int> singleSync(MediaInfo mediaInfo) async {
    try {
      // 请求音频文件下载Url
      MediaUrlRequest req = MediaUrlRequest(mediaId: mediaInfo.mediaId);
      MediaUrlResponse rsp = await DioService.mediaUrl(req);
      if (rsp.code != ErrConstants.SUCCESS_CODE) {
        // todo: 异常处理
        logger.d('文件下载异常' + mediaInfo.mediaId.toString());
        return -1;
      }

      // 下载文件
      Dio dio = Dio();
      // 获取应用程序的文件存储目录
      var dir = await getApplicationDocumentsDirectory();
      // 生成完整的文件路径
      String filePath =
          "${dir.path}/${ensureFileFormat(mediaInfo.mediaName, mediaInfo.fileFormat)}";

      // 下载文件并保存
      await dio.download(rsp.url, filePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          // todo: 下载进度
          logger.d('文件下载进度' + received.toString());
        }
      });

      String transText = "";
      int isTranslated = MediaStateEnum.UPLOADED.state;

      // 更新转写状态
      if (mediaInfo.state == 3) {
        MediaConvertStatusRequest request =
            MediaConvertStatusRequest(mediaId: mediaInfo.mediaId, detail: true);
        MediaConvertStatusResponse response =
            await DioService.mediaConvertStatus(request);

        if (response.code == ErrConstants.SUCCESS_CODE && response.state == 2) {
          transText = json.encode(response.sentenceDetailList);
          isTranslated = MediaStateEnum.TRANSLATED.state;
        }
      }

      // 音频信息写入本地DB
      await recordingService.insertTrans(
          timeLong: mediaInfo.duration,
          fileName: mediaInfo.mediaName,
          originalFileName: mediaInfo.mediaName,
          filePath: filePath,
          mediaId: mediaInfo.mediaId,
          mediaName: mediaInfo.mediaName,
          transText: transText,
          isTranslated: isTranslated,
          source: RecordSourceEnum.APP.source,
          isUpload: CommonConstants.UPLOADED);
    } catch (e) {
      logger.e("Download error: $e");
      return -1;
    }
    return 0;
  }

  Future<void> batchSync(
    dynamic Function(int, int)? mediaSyncCallback,
  ) async {
    List<MediaInfo> mediaList = await loadUnSyncMedia();

    for (var mediaInfo in mediaList) {
      int result = await singleSync(mediaInfo);
      if (result != 0) {
        logger.d("media: ${mediaInfo.mediaName} sync failed.");
      }
      if (mediaSyncCallback != null) {
        mediaSyncCallback(result, mediaInfo.mediaId);
      }
    }
  }

  String ensureFileFormat(String fileName, String fileFormat) {
    // 检查文件名是否以指定的文件格式结尾
    if (!fileName.toLowerCase().endsWith('.$fileFormat')) {
      // 如果没有后缀，则添加上指定的文件格式
      fileName = "$fileName.$fileFormat";
    }
    return fileName;
  }
}
