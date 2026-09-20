import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/page/widget/TooltipShape.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

import '../record/MediaSyncPage.dart';

/**
 * 这是音频文件页的右上角菜单
 */
class PopupMenuWidget extends StatefulWidget {
  const PopupMenuWidget({Key? key}) : super(key: key);
  @override
  State<PopupMenuWidget> createState() => _PopupMenuState();
}

class _PopupMenuState extends State<PopupMenuWidget> {
  final RecordingController dataController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: PopupMenuButton(
        shape: const TooltipShape(),
        padding: EdgeInsets.zero,
        color: Colors.black.withOpacity(0.8),
        offset: const Offset(0, 50),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedMenu01,
          color: Colors.deepOrange,
          size: 20,
        ),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              onTap: () => {
                dataController.sort('updated_at')
                /*ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('按修改时间排序，功能实现中...')),
                )*/
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.sort_sharp,
                          color: dataController.sortColumn.value == 'updated_at'
                              ? Colors.deepOrange
                              : Colors.white,
                          size: 20),
                      SizedBox(width: 10),
                      Text("按修改时间排序",
                          style: TextStyle(
                              color: dataController.sortColumn.value == 'updated_at'
                                  ? Colors.deepOrange
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                  //Divider(indent: 30, color: Colors.grey[400]),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => {
                dataController.sort('created_at')
                /*ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('按创建时间排序，功能实现中...')),
                )*/
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.sort_sharp,
                          color: dataController.sortColumn.value == 'created_at'
                              ? Colors.deepOrange
                              : Colors.white,
                          size: 20),
                      SizedBox(width: 10),
                      Text("按创建时间排序",
                          style: TextStyle(
                              color: dataController.sortColumn.value == 'created_at'
                                  ? Colors.deepOrange
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                  //Divider(indent: 30, color: Colors.grey[400]),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => {
                dataController.filter('全部音频')
                /*ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('筛选已转写文件，功能实现中...')),
                )*/
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.manage_search,
                          color: dataController.selectedFilter.value == '全部音频'
                              ? Colors.deepOrange
                              : Colors.white,
                          size: 20),
                      SizedBox(width: 10),
                      Text("全部音频列表",
                          style: TextStyle(
                              color: dataController.selectedFilter.value == '全部音频'
                                  ? Colors.deepOrange
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                  //Divider(indent: 30, color: Colors.grey[400]),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => {
                dataController.filter('已转写')
                /*ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('筛选已转写文件，功能实现中...')),
                )*/
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.manage_search,
                          color: dataController.selectedFilter.value == '已转写'
                              ? Colors.deepOrange
                              : Colors.white,
                          size: 20),
                      SizedBox(width: 10),
                      Text("已转写列表",
                          style: TextStyle(
                              color: dataController.selectedFilter.value == '已转写'
                                  ? Colors.deepOrange
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                  //Divider(indent: 30, color: Colors.grey[400]),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => {
                dataController.filter('未转写')
                /*ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('筛选未转写文件，功能实现中...')),
                )*/
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.manage_search,
                          color: dataController.selectedFilter.value == '未转写'
                              ? Colors.deepOrange
                              : Colors.white,
                          size: 20),
                      SizedBox(width: 10),
                      Text("未转写列表",
                          style: TextStyle(
                              color: dataController.selectedFilter.value == '未转写'
                                  ? Colors.deepOrange
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                  //Divider(indent: 30, color: Colors.grey[400]),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('批量上传云端，功能实现中...')),
                )
              },
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text("批量上传云端",
                          style: TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal)),
                    ],
                  ),
                  //Divider(indent: 30, color: Colors.grey[400]),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const MediaSyncPage()))
              },
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_download_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("云端文件同步",
                          style: TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal)),
                    ],
                  ),
                  //Divider(indent: 30, color: Colors.grey[400]),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }
}
