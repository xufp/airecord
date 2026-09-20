import 'package:flutter/material.dart';
import '../widget/ItemWidget.dart';
import 'package:get/get.dart';
import 'package:airecordapp/controller/RecordingController.dart';
import 'package:flutter/services.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

/**
 * 文件列表内容
 */
class SearchFilePage extends StatefulWidget {
  @override
  _SearchFilePageState createState() => _SearchFilePageState();
}

class _SearchFilePageState extends State<SearchFilePage> {
  final RecordingController dataController =
      Get.put(RecordingController(getAll: false), tag: 'searchPageController');

  @override
  void initState() {
    super.initState();
    // 设置状态栏文字颜色为深色
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    // 页面刚进来默认查询所有数据
    _getAllList();
  }

  // 页面刚进来默认查询所有数据
  void _getAllList() {
    dataController.getAllList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFE5E5E5),
                          width: 0.5,
                        ),
                      ),
                      child: TextField(
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1A1A1A),
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF666666),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          hintText: S.of(context).SearchFilePage_k1,
                          hintStyle: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          dataController.search(value);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      S.of(context).SearchFilePage_k2,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ItemWidget(tag: 'searchPageController'),
          ),
        ],
      ),
    );
  }
}
