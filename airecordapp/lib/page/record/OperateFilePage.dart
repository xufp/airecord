import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/logic/RadioLogic.dart';
import 'package:airecordapp/page/HomePage.dart';
import 'package:airecordapp/page/widget/OperateItemWidget.dart';
import 'package:airecordapp/service/RecordingService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airecordapp/controller/RecordingController.dart';
import 'package:flutter/services.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

/**
 * 删除/重命名文件
 */
class OperateFilePage extends StatefulWidget {
  @override
  _OperateFilePageState createState() => _OperateFilePageState();
}

class _OperateFilePageState extends State<OperateFilePage> {
  late final RecordingController dataController;
  final BlueController blueController = Get.find();

  RecordingService recordingService = RecordingService();
  RadioLogic radioLogic = RadioLogic();

  // 兼容原有重命名/删除逻辑：以 index 为 key 临时塞入，操作完成后清理
  Map<String, bool> _cardSelected = {};
  bool _deleteRecording = false; // 记录复选框的状态

  /// 单文件重命名入口
  void _renameOne(int index) {
    if (index < 0 || index >= dataController.dataList.length) return;
    _cardSelected
      ..clear()
      ..[index.toString()] = true;
    _renameFileController = TextEditingController(
      text: dataController.dataList[index].fileName,
    );
    _rename(index);
  }

  /// 单文件删除入口
  void _deleteOne(int index) {
    if (index < 0 || index >= dataController.dataList.length) return;
    _cardSelected
      ..clear()
      ..[index.toString()] = true;
    _deleteRecording = false; // 每次单文件删除前重置设备同删勾选
    confirmDeleteDialog();
  }

  //重命名文件
  TextEditingController? _renameFileController = null;

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
    // 使用 Get.find 尝试查找已存在的controller，如果不存在则创建新的
    try {
      dataController = Get.find<RecordingController>(tag: 'operatePageController');
    } catch (e) {
      dataController = Get.put(RecordingController(getAll: true), tag: 'operatePageController', permanent: true);
    }
    // 使用 addPostFrameCallback 确保在构建完成后加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAllList();
    });
  }

  // 页面刚进来默认查询所有数据
  void _getAllList() {
    dataController.getAllList();
  }

  @override
  void dispose() {
    // 不要在dispose中销毁controller
    super.dispose();
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
                          hintText: S.of(context).OperateFilePage_k1,
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
                      Get.to(HomePage());
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      S.of(context).OperateFilePage_k2,
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
            child: OperateItemWidget(
              tag: 'operatePageController',
              onRename: _renameOne,
              onDelete: _deleteOne,
            ),
          ),
        ],
      ),
    );
  }

  void confirmDelete(context) async {
    if (_cardSelected.length > 0) {
      Iterable<String> keys = _cardSelected.keys;
      List<Recording> recordList = [];
      for (String key in keys) {
        recordList.add(dataController.dataList[int.parse(key)]);
      }
      bool result = await radioLogic.batchMediaRemove(recordList);
       // 判断是否选中了删除录音笔音频文件
      if (_deleteRecording) {
        blueController.delFile(recordList);
      }
      if (result) {
        Navigator.of(context).pop(true);
        setState(() {
          dataController.reloadData();
          _cardSelected.clear();
        });
      }
    }
  }

  /**
   * 编辑文件名称
   */
  void _rename(int index) {
    showModalBottomSheet(
      context: context,
      elevation: 0,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).OperateFilePage_k5,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Color(0xFF666666)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                Divider(height: 24, thickness: 1, color: Colors.grey[200]),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFFE5E5E5),
                      width: 0.5,
                    ),
                  ),
                  child: TextFormField(
                    controller: _renameFileController,
                    cursorColor: Colors.blue,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 1,
                        ),
                      ),
                      hintText: S.of(context).OperateFilePage_k6,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            S.of(context).OperateFilePage_k7,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _saveFileName(index),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.blue.shade700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            S.of(context).OperateFilePage_k8,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /**
   * 保存文件名
   */
  void _saveFileName(int index) {
    Recording _recording = dataController.dataList[index];
    String fileName = _renameFileController!.text;
    if (fileName == null || fileName.isEmpty) {
      showAlertDialog(S.of(context).OperateFilePage_k9);
    } else {
      recordingService.updateFileName(_recording.id!, fileName);
      Navigator.pop(context);
      setState(() {
        _recording.fileName = fileName;
      });
    }
  }

  /**
   * 显示提示框
   */
  void showAlertDialog(String msg) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          AlertDialog alertDialog = AlertDialog(
              backgroundColor: Colors.black.withOpacity(0.8),
              alignment: Alignment.center,
              //title: Text(''),
              content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      msg,
                      style: TextStyle(color: Colors.white),
                    ),
                  ]));
          //提示框显示1秒后关闭
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(dialogContext).pop();
          });
          return alertDialog;
        });
  }

  void confirmDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Icon(
                      Icons.delete_outline,
                      color: Color(0xFF6C63FF),
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    S.of(context).OperateFilePage_k10,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    S.of(context).OperateFilePage_k11,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (blueController.isConnected.value) ...[
                    SizedBox(height: 12),
                    CheckboxListTile(
                      title: Text(
                        S.of(context).OperateFilePage_k12,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      value: _deleteRecording,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          _deleteRecording = value ?? false;
                        });
                      },
                      activeColor: Color(0xFF6C63FF),
                      contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    S.of(context).OperateFilePage_k13,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => confirmDelete(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  child: Text(
                    S.of(context).OperateFilePage_k14,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}


