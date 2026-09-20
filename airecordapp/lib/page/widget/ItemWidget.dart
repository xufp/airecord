import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/enum/RecordSourceEnum.dart';
import 'package:airecordapp/service/RecordingService.dart';
import 'package:airecordapp/util/DateUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

/**
 * 音频文件列表
 */
class ItemWidget extends StatelessWidget {
  RecordingController dataController = Get.find();
  RecordingService recordingService = RecordingService();
  Function? refreshData = null;

  ItemWidget({super.key, String? tag, Function? refreshData}) {
    if (tag == 'searchPageController') {
      dataController = Get.find(tag: 'searchPageController');
    }
    this.refreshData = refreshData;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (dataController.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
        );
      }

      Widget listBuilder(BuildContext context, int index) {
        final recording = dataController.dataList[index];
        print('timelong:' + recording.timeLong.toString());
        final String recordTime = DateUtil.formatSeconds(recording.timeLong);
        return Slidable(
          key: Key(recording.mediaId.toString()),
          direction: Axis.horizontal,
          closeOnScroll: true,
          child: Container(
            margin: EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFE5E5E5).withOpacity(0.6),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6C63FF).withOpacity(0.02),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await Navigator.pushNamed(
                    context, 
                    '/player',
                    arguments: {'recording': recording}
                  );
                  dataController.reloadData();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题和时长
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              recording.fileName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 12),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F7FA).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(0xFFEEEEEE).withOpacity(0.6),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Color(0xFF666666).withOpacity(0.8),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  recordTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF666666).withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      
                      // 底部信息栏
                      Row(
                        children: [
                          // 创建时间
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F7FA).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(0xFFEEEEEE).withOpacity(0.6),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Color(0xFF666666).withOpacity(0.8),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  DateUtil.formatMillisecond(recording.updatedAt, DateUtil.YMD_HMS_STD),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF666666).withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),

                          // 来源标签：去掉「录音笔/新款录音笔」标签，仅在「导入/APP」时展示
                          if (recording.source != RecordSourceEnum.PEN.source &&
                              recording.source !=
                                  RecordSourceEnum.PEN_V2.source &&
                              _getSourceDesc(context, recording.source)
                                  .isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color(0xFF6C63FF).withOpacity(0.03),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Color(0xFF6C63FF).withOpacity(0.08),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    size: 14,
                                    color: Color(0xFF6C63FF).withOpacity(0.8),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _getSourceDesc(context, recording.source),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6C63FF).withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // 占位填满，让 AI 转写按钮靠右
                          Spacer(),

                          // AI 转写按钮：突出 AI 能力，点击进入播放/转写页
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/player',
                                  arguments: {'recording': recording},
                                );
                                dataController.reloadData();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6C63FF),
                                      Color(0xFF8B7BFF),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF6C63FF)
                                          .withOpacity(0.18),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: 12,
                                        color: Color(0xFF6C63FF),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      S.of(context).ItemWidget_AI,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      if (dataController.dataList.isEmpty) {
        return SlidableAutoCloseBehavior(
          child: RefreshIndicator(
            color: Color(0xFF6C63FF),
            backgroundColor: Colors.white,
            displacement: 40,
            strokeWidth: 2.5,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFFEEEEEE),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.folder_outlined,
                            size: 32,
                            color: Color(0xFF666666),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          S.of(context).ItemWidget_k1,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          S.of(context).ItemWidget_k2,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            onRefresh: () async {
              if (refreshData != null) {
                await refreshData!();
              }
            },
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            dataController.loadMore();
          }
          return true;
        },
        child: SlidableAutoCloseBehavior(
          child: RefreshIndicator(
            color: Color(0xFF6C63FF),
            backgroundColor: Colors.white,
            displacement: 40,
            strokeWidth: 2.5,
            child: Container(
              color: Color(0xFFF5F7FA),
              child: ListView.builder(
                padding: EdgeInsets.only(top: 12, bottom: 20, left: 0, right: 0),
                itemCount: dataController.dataList.length,
                itemBuilder: listBuilder,
              ),
            ),
            onRefresh: () async {
              if (refreshData != null) {
                await refreshData!();
              }
            },
          ),
        ),
      );
    });
  }

  String _getSourceDesc(BuildContext context, String source) {
    if (source == RecordSourceEnum.PEN.source) {
      return S.of(context).RecordSourceEnum_pen;
    } else if (source == RecordSourceEnum.IMPORT.source) {
      return S.of(context).RecordSourceEnum_import;
    } else if (source == RecordSourceEnum.APP.source) {
      return 'APP';
    }
    return '';
  }
}