import 'package:airecordapp/controller/TradeRecordController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class TradeRecordPage extends StatefulWidget {
  TradeRecordPage();

  @override
  State<TradeRecordPage> createState() => _TradeRecordState();
}

class _TradeRecordState extends State<TradeRecordPage> {
  TradeRecordController dataController = Get.put(TradeRecordController());

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
          S.of(context).TradeRecordPage_k1,
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
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Color(0xFFCCCCCC),
                ),
                SizedBox(height: 16),
                Text(
                  S.of(context).TradeRecordPage_k2,
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

                return Slidable(
                  key: Key(recording.orderId.toString()),
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
                                    recording.packageName,
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
                                    '${S.of(context).TradeRecordPage_k3}: ${recording.orderId}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${S.of(context).TradeRecordPage_k4}: ${recording.payTime}',
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
                                  '\$${(recording.amount/100).toStringAsFixed(2)}',
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

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return S.of(context).TradeRecordPage_k6;
      case 2:
        return S.of(context).TradeRecordPage_k7;
      case 3:
        return S.of(context).TradeRecordPage_k8;
      default:
        return '';
    }
  }
}
