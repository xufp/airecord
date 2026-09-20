import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/util/LogUtil.dart';

import '../../logic/MediaSyncLogic.dart';
import '../../service/response/MediaSyncResponse.dart';
import 'package:get/get.dart';

/**
 * 音频文件同步逻辑
 */
class MediaSyncController extends GetxController {
  final RecordingController dataController = Get.find<RecordingController>();
  MediaSyncLogic mediaSyncLogic = MediaSyncLogic();
  final logger = LogUtil.inItLog();
  var mediaList = <MediaInfo>[].obs;
  var syncedCount = 0.obs;
  var isSyncing = false.obs;
  var isLoadFinish = false.obs;

  // 计算同步进度
  double get progress =>
      mediaList.isEmpty ? 0 : syncedCount.value / mediaList.length;

  Future<void> loadUnSyncMedia() async {
    isLoadFinish.value = false;
    mediaList.value = await mediaSyncLogic.loadUnSyncMedia();
    isLoadFinish.value = true;
  }

  // 开始同步的逻辑
  Future<void> startSync() async {
    if (mediaList.isEmpty) {
      logger.d('无音频文件同步');
      return;
    }
    if (syncedCount.value == mediaList.length) {
      return;
    }
    isSyncing.value = true;
    syncedCount.value = 0;
    for (MediaInfo media in mediaList) {
      media.syncStatus = 1;

      int result = await mediaSyncLogic.singleSync(media);
      if (result == 0) {
        media.syncStatus = 2;
        dataController.getAllList();
      } else {
        media.syncStatus = 3;
      }
      syncedCount.value++;
    }
    isSyncing.value = false;
  }
}
