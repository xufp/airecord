import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/controller/BlueControllerV2.dart';
import 'package:airecordapp/controller/MediaSyncController.dart';
import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:airecordapp/logic/ProfileLogic.dart';
import 'package:airecordapp/page/record/ListPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'center/ProfilePage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final RecordingController dataController = Get.put(RecordingController());
  // 一定要为单例
  final BlueController blueController =
      Get.put(BlueController(), permanent: true);
  // 新硬件 V2 控制器：与 V1 并行共存，互不影响
  final BlueControllerV2 blueControllerV2 =
      Get.put(BlueControllerV2(), permanent: true);
  final MediaSyncController mediaSyncController =
      Get.put(MediaSyncController());
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  ProfileLogic logic = ProfileLogic();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _initialize() async {
    // 蓝牙设备自动连接
    blueController.deviceListen();
    // 检查用户信息是否变更，发生变更则刷新页面
    logic.isChanged().then((value) {
      if (value) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (dataController != null) {
      dataController.dispose();
    }
    //dataController.dispose();
  }

  // 底部导航栏索引
  int _bottomBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ListPage(_scaffoldKey),
      ProfilePage(),
    ];
    return Scaffold(
      key: _scaffoldKey,
      body: pages[_currentIndex],
      //drawer: LeftDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _bottomBarIndex = index;
          if (index == 0) {
            setState(() {
              _currentIndex = 0;
            });
          } else if (index == 1) {
            setState(() {
              _currentIndex = 1;
            });
          }
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: _buildBottomBarItem,
        currentIndex: _bottomBarIndex,
        unselectedItemColor: Colors.grey[500],
        selectedItemColor: Colors.lightBlue,
        //showUnselectedLabels: false,  // 不显示未选中项的标签
        //showSelectedLabels: false,
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontFamily: 'PingFang SC-Semibold',
        ),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          fontFamily: 'PingFang SC-Semibold',
        ),
      ),
    );
  }

// 生成底部导航按钮
  List<BottomNavigationBarItem> get _buildBottomBarItem {
    return [
      BottomNavigationBarItem(
          icon: _bottomBarIndex == 0
              ? Image.asset(
                  'assets/images/folder-minus-open.png',
                  width: 25,
                  height: 25,
                  color: Colors.lightBlue,
                )
              : Image.asset(
                  'assets/images/folder-minus-close.png',
                  width: 25,
                  height: 25,
                  //color: Colors.black,
                ),
          label: S.of(context).HomePage_menu_filelist),
      BottomNavigationBarItem(
          icon: _bottomBarIndex == 1
              ? Image.asset(
                  'assets/images/user_4_fill.png',
                  width: 25,
                  height: 25,
                  color: Colors.lightBlue,
                )
              : Image.asset(
                  'assets/images/user_4_line.png',
                  width: 25,
                  height: 25,
                  //color: Colors.black,
                ),
          label: S.of(context).HomePage_menu_usercenter),
    ];
  }
}
