import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:airecordapp/service/RecordingService.dart';
import 'package:airecordapp/util/DateUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class OperateItemWidget extends StatefulWidget {
  final String? tag;

  /// 单文件重命名回调，参数为列表中的 index
  final void Function(int index)? onRename;

  /// 单文件删除回调，参数为列表中的 index
  final void Function(int index)? onDelete;

  const OperateItemWidget({
    super.key,
    this.tag,
    this.onRename,
    this.onDelete,
  });

  @override
  State<StatefulWidget> createState() {
    return _OperateItemState();
  }
}

/**
 * 音频文件列表
 */
class _OperateItemState extends State<OperateItemWidget> {
  RecordingController dataController = Get.find(tag: 'operatePageController');
  RecordingService recordingService = RecordingService();

  void _refreshData() async {
    setState(() {
      dataController.reloadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (dataController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      Widget listBuilder(BuildContext context, int index) {
        final recording = dataController.dataList[index];
        final String recordTime = DateUtil.formatSeconds(recording.timeLong);

        return Slidable(
          key: Key(recording.mediaId.toString()),
          //滑动方向
          direction: Axis.horizontal,
          closeOnScroll: true,
          child: Card(
            margin: const EdgeInsets.fromLTRB(8, 10, 8, 0),
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(0xFFEFEFEF), width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 文件名
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      recording.fileName,
                      style: TextStyle(
                        fontFamily: 'Inter-Medium',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(height: 8),
                  // 元信息（创建时间 / 时长）
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 14,
                        color: Color(0xFF999999),
                      ),
                      SizedBox(width: 4),
                      Text(
                        DateUtil.formatMillisecond(
                            recording.createdAt, DateUtil.YMD_HMS_STD),
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF999999),
                      ),
                      SizedBox(width: 4),
                      Text(
                        recordTime,
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  // 分割线
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Color(0xFFF0F0F0),
                  ),
                  // 单行操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildItemAction(
                        icon: Icons.edit_outlined,
                        label: S.of(context).OperateFilePage_k3, // 重命名
                        color: Color(0xFF6C63FF),
                        onTap: () => widget.onRename?.call(index),
                      ),
                      SizedBox(width: 4),
                      _buildItemAction(
                        icon: Icons.delete_outline,
                        label: S.of(context).OperateFilePage_k4, // 删除
                        color: Color(0xFFE05B5B),
                        onTap: () => widget.onDelete?.call(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (dataController.dataList.isEmpty) {
        return SlidableAutoCloseBehavior(
          child: RefreshIndicator(
            color: Colors.blue,
            backgroundColor: Colors.white,
            displacement: 40,
            strokeWidth: 2.5,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 120),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/folder-empty.png',
                        width: 60,
                        height: 60,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      Text(
                        S.of(context).OperateItemWidget_k1,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Inter-Medium'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onRefresh: () async {
              _refreshData();
            },
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              dataController.loadMore();
            }
            return true;
          },
          child: SlidableAutoCloseBehavior(
            child: RefreshIndicator(
              color: Colors.blue,
              backgroundColor: Colors.white,
              displacement: 40,
              strokeWidth: 2.5,
              child: ListView.builder(
                itemCount: dataController.dataList.length,
                itemBuilder: listBuilder,
              ),
              onRefresh: () async {
                _refreshData();
              },
            ),
          ));
    });
  }

  /// 单行操作按钮（重命名 / 删除）
  Widget _buildItemAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
