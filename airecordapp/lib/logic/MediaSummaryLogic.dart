import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/enum/MediaStateEnum.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/RecordingService.dart';
import 'package:airecordapp/service/request/MediaSummaryStatusRequest.dart';
import 'package:airecordapp/service/response/MediaSummaryResponse.dart';
import 'package:airecordapp/service/response/MediaSummaryStatusResponse.dart';

import 'RadioLogic.dart';

/**
 * 音频总结
 */
class MediaSummary {
  final Recording _recording;

  RecordingService recordingService = RecordingService();
  RadioLogic radioLogic = RadioLogic();

  String promptId = '';

  MediaSummary(this._recording, this.mediaId, this.promptId);

  int? mediaId;

  Future<void> _execSummary(
      {dynamic Function(int, String, String)? summaryCallback}) async {
    MediaSummaryResponse response =
        await radioLogic.mediaSummary(mediaId ?? 0, promptId);

    if(response.code == ErrConstants.MEDIA_SUMMARY_TOO_SHORT_CODE) {
      String summaryText = response.msg ?? "Text is too short to summarize";
      // 更新总结文案到数据库
      recordingService.updateSummaryText(
          _recording.id!, MediaStateEnum.SUMMARYED.state, summaryText);
      if (summaryCallback != null) {
        summaryCallback(ErrConstants.SUCCESS_CODE, "success", summaryText);
      }
      return;
    } else if (response.code != ErrConstants.SUCCESS_CODE) {
      if (summaryCallback != null) {
        summaryCallback(response.code, response.msg, "");
      }
      return;
    }

    int i = 0;
    while (i < 150) {
      MediaSummaryStatusRequest request =
          MediaSummaryStatusRequest(mediaId: this.mediaId ?? 0);
      MediaSummaryStatusResponse response =
          await DioService.mediaSummaryStatus(request);
      if (response.code != ErrConstants.SUCCESS_CODE) {
        print("拉取总结结果失败：$response");
        break;
      }

      // 结果正常
      if (response.state == 2) {
        var summaryText = response.content == null || response.content!.isEmpty
            ? ""
            : response.content!;
        // 更新总结文案到数据库
        recordingService.updateSummaryText(
            _recording.id!, MediaStateEnum.SUMMARYED.state, summaryText);

        if (summaryCallback != null) {
          summaryCallback(ErrConstants.SUCCESS_CODE, "success", summaryText);
          return;
        }
        break;
      }
      // 延迟两秒处理结果
      await Future.delayed(const Duration(seconds: 2));
      i++;
    }
    print("pull summary result more then 5 minutes");
  }

  Future<void> mediaSummary({
    dynamic Function(int, String, String)? summaryCallback,
  }) async {
    _execSummary(summaryCallback: summaryCallback);
  }
}
