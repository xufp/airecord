import 'package:airecordapp/controller/MediaSyncController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MediaSyncPage extends StatefulWidget {
  const MediaSyncPage({super.key});

  @override
  _SyncPageState createState() => _SyncPageState();
}

class _SyncPageState extends State<MediaSyncPage> {
  MediaSyncController mediaSyncController = Get.find();

  @override
  void initState() {
    super.initState();
    mediaSyncController.loadUnSyncMedia();
  }

  // 处理返回退出的逻辑
  Future<bool> _onWillPop() async {
    return true; // 如果没有同步，直接退出
    if (mediaSyncController.isSyncing.value) {
      bool shouldExit = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              backgroundColor: Colors.grey[100],
              content: const Text(
                '退出当前页面，未完成同步的音频将被终止？',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4), // 缩小底部间距
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("取消"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text("确认"),
                    ),
                  ],
                )
              ],
            ),
          ) ??
          false;

      return shouldExit;
    } else {
      return true; // 如果没有同步，直接退出
    }
  }

  // 根据文件状态显示不同的图标
  Widget _buildStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icon(Icons.downloading_outlined, color: Colors.grey);
      case 1:
        return SizedBox(
          width: 20, // 设置宽度
          height: 20, // 设置高度
          child: CircularProgressIndicator(
            color: Colors.grey, // 设置颜色
            strokeWidth: 2.0, // 设置圆圈线条宽度
          ),
        );
      case 2:
        return Icon(Icons.check_circle_outline, color: Colors.green);
      case 3:
        return Icon(Icons.error_outline, color: Colors.red);
      default:
        return SizedBox.shrink(); // 空的占位符
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 拦截返回事件
      child: Scaffold(
        appBar: AppBar(
          title: Text("云端文件同步"),
          backgroundColor: Colors.white,
        ),
        // backgroundColor: Colors.grey[100],
        body: Obx(() {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: mediaSyncController.mediaList.isNotEmpty
                ? Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: mediaSyncController.mediaList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.white, // 设置 Card 背景颜色为白色
                              elevation: 2, // 设置卡片的阴影效果
                              margin: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8), // 设置卡片的边距
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 8, 16, 8), // 设置内部填充
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 文件名
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mediaSyncController
                                              .mediaList[index].mediaName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          mediaSyncController
                                              .mediaList[index].recordTime,
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    // 同步状态图标
                                    _buildStatusIcon(mediaSyncController
                                        .mediaList[index].syncStatus),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      // 居中的大圆形进度条
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            mediaSyncController.isSyncing.value
                                ? SizedBox(
                                    height: 90,
                                    width: 90,
                                    child: Container(
                                      padding:
                                          const EdgeInsets.all(16.0), // 设置内边距
                                      child: CircularProgressIndicator(
                                        color: Colors.grey[500], // 可选：自定义颜色
                                        // value: 1,
                                        strokeWidth: 8,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: 90,
                                    width: 90,
                                  ),
                            SizedBox(
                              height: 90,
                              width: 90,
                              child: Container(
                                padding: const EdgeInsets.all(16.0), // 设置内边距
                                child: CircularProgressIndicator(
                                  color: Colors.green, // 可选：自定义颜色
                                  value: mediaSyncController.isSyncing.value
                                      ? mediaSyncController.progress
                                      : 0,
                                  strokeWidth: 8,
                                ),
                              ),
                            ),
                            mediaSyncController.isSyncing.value
                                ? Text(
                                    "${(mediaSyncController.progress * 100).toStringAsFixed(0)}%",
                                    style: TextStyle(fontSize: 18),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                            alignment:
                                Alignment.bottomCenter, // 对齐到Container的底部
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue, Colors.purple],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26, // 阴影颜色
                                    blurRadius: 5.0, // 阴影模糊半径
                                    offset: Offset(2, 2), // 阴影偏移量
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.symmetric(vertical: 25),
                              child: TextButton(
                                  onPressed: mediaSyncController.isSyncing.value
                                      ? null
                                      : (mediaSyncController
                                                  .syncedCount.value !=
                                              mediaSyncController
                                                  .mediaList.length
                                          ? mediaSyncController.startSync
                                          : null),
                                  child: Text(
                                    mediaSyncController.isSyncing.value
                                        ? "同步中..."
                                        : (mediaSyncController
                                                    .syncedCount.value !=
                                                mediaSyncController
                                                    .mediaList.length
                                            ? "开始同步"
                                            : "同步完成"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(
                                        Size(300, 20)),
                                  )),
                            )),
                      ),
                      SizedBox(height: 30)
                    ],
                  )
                : mediaSyncController.isLoadFinish.value
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.search_rounded,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              '没有待同步的音频文件',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 160),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                              color: Colors.grey, // 设置颜色
                              strokeWidth: 4.0, // 设置圆圈线条宽度
                            ),
                            SizedBox(height: 20),
                            Text(
                              '正在加载音频文件...',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 160),
                          ],
                        ),
                      ),
          );
        }),
      ),
    );
  }
}
