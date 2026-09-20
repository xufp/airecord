import 'package:airecordapp/controller/ConvertRecordController.dart';
import 'package:airecordapp/util/DateUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class ConvertRecordPage extends StatefulWidget {
  ConvertRecordPage();

  @override
  State<ConvertRecordPage> createState() => _ConvertRecordState();
}

class _ConvertRecordState extends State<ConvertRecordPage> {
  ConvertRecordController dataController = Get.put(ConvertRecordController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          S.of(context).ConvertRecordPage_k1,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: Obx(() {
        if (dataController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF2196F3),
                  strokeWidth: 2.0,
                ),
                SizedBox(height: 16),
                Text(
                  '加载中',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          );
        }

        if (dataController.dataList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.audio_file_outlined,
                  size: 64,
                  color: Color(0xFFCCCCCC),
                ),
                SizedBox(height: 16),
                Text(
                  S.of(context).ConvertRecordPage_k2,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
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
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: dataController.dataList.length,
              itemBuilder: (context, index) {
                final recording = dataController.dataList[index];
                final String duration = DateUtil.formatSeconds(recording.duration ~/ 1000);

                return Slidable(
                  key: Key(recording.mediaId.toString()),
                  direction: Axis.horizontal,
                  closeOnScroll: true,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => dataController.reloadData(),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recording.mediaName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${S.of(context).ConvertRecordPage_k3}: ${recording.recTime} ${S.of(context).ConvertRecordPage_k5}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F7FA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '-' + duration,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2196F3),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
