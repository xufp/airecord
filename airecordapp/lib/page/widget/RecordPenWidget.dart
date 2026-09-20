import 'dart:async';

import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/logic/LoadConfigLogic.dart';
import 'package:airecordapp/page/HomePage.dart';
import 'package:airecordapp/util/DateUtil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class RecordPenWidget extends StatefulWidget {
  @override
  _RecordPenWidgetState createState() => _RecordPenWidgetState();
}

class _RecordPenWidgetState extends State<RecordPenWidget>
    with SingleTickerProviderStateMixin {
  final RecordingController dataController = Get.find();
  final BlueController blueController = Get.find();
  final ScrollController _scrollController = ScrollController();
  int startTime = 0;
  // 录音效果数据
  final List<Color> recordColors = [
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black
  ];
  final List<int> recordDuration = [900, 700, 600, 800, 500];

  //选中的转写引擎
  String _engineType = "";
  //选中的语言名称
  String _engineDesc = "";

  late LoadConfigLogic loadConfigLogic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadConfigLogic = LoadConfigLogic(context);
      _showLanguageSelectionDialog();
    });
  }

  Future<void> _showLanguageSelectionDialog() async {
    final response = await loadConfigLogic.getAsrEngineModels();
    final languages = response.data ?? [];
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.language, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        S.of(context).RecordPenWidget_k1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: languages.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.withOpacity(0.1),
                        indent: 20,
                        endIndent: 20,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final language = languages[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              print('Selected engine type: ${language.engineType}');
                              Navigator.of(context).pop(true); // 选择语言返回 true
                              setState(() {
                                _engineType = language.engineType;
                                _engineDesc = language.engineDesc;
                              });
                              _initializeRecorder();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      language.engineDesc ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey.withOpacity(0.5),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // 用户未选择语言就退出（返回键），跳转回首页
    if (!mounted || result != true || _engineType.isEmpty) {
      if (mounted) {
        tranCancel();
      }
    }
  }

  // 录音笔初始化
  Future<void> _initializeRecorder() async {
    blueController.engineType = _engineType;
    if (!blueController.isRecording.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        blueController.startTran();
      });
    }
  }

  @override
  void dispose() {
    blueController.clearTranSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      blueController.clearTranFile();
    });
    super.dispose();
  }

  tranCancel() async {
    blueController.tranCancel();
    Get.to(HomePage()); // 跳转回首页
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // 返回时重定向到列表页
        tranCancel();
      },
      child: Obx(() {
        return Stack(children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                S.of(context).RecordPenWidget_k1,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: true,
              actions: [
                Text(
                  _engineDesc, // 标题
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16, // 调整标题字号
                    fontWeight: FontWeight.w300, // 调整字重
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
            body: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Expanded(flex: 65, child: _buildTransText()),
                    SizedBox(height: 20),
                    Expanded(
                      flex: 15,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SelectableText(
                              blueController.transIngSkText.value,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  DateUtil.formatDuration(blueController.recordingDurationMs.value ~/ 1000),
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              )
                            ),
                            Expanded(
                              flex: 8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 28),
                                  Container(
                                    width: 56,
                                    height: 56,
                                    margin: EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        blueController.isRecording.value
                                            ? (blueController.isPaused.value ? Icons.mic : Icons.pause)
                                            : Icons.mic,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: blueController.isRecording.value
                                          ? (blueController.isPaused.value
                                              ? blueController.tranResume
                                              : blueController.tranPause)
                                          : blueController.startTran,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.stop, color: Colors.red, size: 28),
                                    onPressed: tranCancel,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]);
      }),
    );
  }

  Widget _buildTransText() {
    return ListView.separated(
      controller: _scrollController,
      itemCount: blueController.sentenceDetailList.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.withOpacity(0.1),
        indent: 20,
        endIndent: 20,
      ),
      itemBuilder: (context, index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        
        final item = blueController.sentenceDetailList[index];
        final isLastItem = index == blueController.lastAddedIndex;
        int displayTime = blueController.sentenceDetailList[index].startTime - startTime;
        String displayTimeStr = DateUtil.formatMilliseconds(displayTime);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 15,
                      color: Color(0xFFABADC0),
                    ),
                    SizedBox(width: 5),
                    Text(
                      displayTimeStr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFABADC0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: SelectableText(
                  item.text + (isLastItem ? blueController.transIngSkText.value : ''),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: isLastItem ? Colors.blue : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
