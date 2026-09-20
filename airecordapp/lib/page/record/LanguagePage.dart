import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:airecordapp/page/blue/DevicePage.dart';
import 'package:airecordapp/page/blue/PenPageList.dart';
import 'package:airecordapp/page/record/AssistantPage.dart';
import 'package:airecordapp/page/record/OperateFilePage.dart';
import 'package:airecordapp/page/record/RecordPage.dart';
import 'package:airecordapp/page/widget/ItemWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

/**
 * 语言选择页面
 */
class LanguagePage extends StatefulWidget {
  Function(int value)? selectedLanguage;

  LanguagePage(this.selectedLanguage);

  @override
  State<LanguagePage> createState() => _LanguageState();
}

class _LanguageState extends State<LanguagePage> {
  final RecordingController dataController = Get.find();
  final BlueController blueController = Get.find();

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
      backgroundColor: Colors.white,
      //drawerScrimColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.purple.withOpacity(0.2)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                ),
              ),
            ),
            AppBar(
              title: Text(''),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              toolbarHeight: 160,
              elevation: 0,
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                // 同时检查设备是否已连接和设备名称
                                if (blueController.isConnected.value) {
                                  // 设备已连接，直接跳转到设备页面
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => DevicePage()));
                                } else {
                                  blueController.platformName.then((devName) {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => devName == ''
                                            ? PenPageList()
                                            : DevicePage()));
                                  });
                                }
                              },
                              child: Container(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/device.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '智能硬件',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                //Get.to(() => RecordPage());
                                if (!blueController.isConnected.value) {
                                  //没有连接设备，弹出提示
                                  showAlertDialog('设备未连接，请连接设备后再使用',
                                      redirectPage: '/bluetooth');
                                } else {
                                  Get.to(() => RecordPage());
                                }
                              },
                              child: Container(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/voice-record.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '录音速记',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //if (blueController.isConnected.value)
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                if (!blueController.isConnected.value) {
                                  //没有连接设备，弹出提示
                                  showAlertDialog('设备未连接，请连接设备后再使用',
                                      redirectPage: '/bluetooth');
                                } else {
                                  Get.to(() => RecordPage());
                                }
                              },
                              child: Container(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/translate.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '同声传译',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                if (!blueController.isConnected.value) {
                                  //没有连接设备，弹出提示
                                  showAlertDialog('设备未连接，请连接设备后再使用',
                                      redirectPage: '/bluetooth');
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AssistantPage()));
                                }
                              },
                              child: Container(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/ai-assistant.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'AI翻译',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                if (!blueController.isConnected.value) {
                                  //没有连接设备，弹出提示
                                  showAlertDialog('设备未连接，请连接设备后再使用',
                                      redirectPage: '/bluetooth');
                                } else {}
                              },
                              child: Container(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/dialogue.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '语音对话',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.purple.withOpacity(0.2)
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Obx(() {
                          return Text(
                            S.of(context).ListPage_menu_name +
                                '(${dataController.dataList.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'PingFang SC-Semibold',
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/search');
                                },
                                child: Icon(
                                  Icons.search,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                style: ElevatedButton.styleFrom(
                                  //minimumSize: Size(30, 10),
                                  // 设置按钮的最小尺寸
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 35,
                              height: 35,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => OperateFilePage(),
                                  ));
                                },
                                child: HugeIcon(
                                  icon: HugeIcons
                                      .strokeRoundedLeftToRightListBullet,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                style: ElevatedButton.styleFrom(
                                  //minimumSize: Size(30, 10),
                                  // 设置按钮的最小尺寸
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: ItemWidget(
                        //refreshData: _refreshData,
                        ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /**
   * 显示提示框
   *
   */
  void showAlertDialog(String msg, {String redirectPage = ""}) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          AlertDialog alertDialog = AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            backgroundColor: Colors.white,
            elevation: 10,
            alignment: Alignment.center,
            content: Container(
              alignment: Alignment.center,
              height: 70,
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            // 缩小底部间距
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 1.0),
                            right: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Text(
                          '取消',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(dialogContext).pop(true);
                        // 跳转页面
                        if (redirectPage != "") {
                          Navigator.pushNamed(context, redirectPage);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey, width: 1.0),
                            left: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Text(
                          '连接',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
          return alertDialog;
        });
  }
}
