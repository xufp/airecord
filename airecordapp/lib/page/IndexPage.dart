import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/page/record/RecordPage.dart';
import 'center/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:get/get.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<IndexPage> {
  int _currentIndex = 0;
  final BlueController blueController = Get.put(BlueController());

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> pages = [
    //ListPage(),
    ProfilePage(),
  ];

  List<BottomNavigationBarItem> _changeBarItem() {
    List<BottomNavigationBarItem> defaultBarItem = [
      BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedScroll,
          color: Colors.grey,
        ),
        //icon: Icon(Icons.file_copy_outlined, size: 30),
        label: '音频文件',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(
            icon: HugeIcons.strokeRoundedAddCircle,
            color: Colors.deepOrange,
            size: 30),
        label: '更多',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedUserCircle,
          color: Colors.grey,
        ),
        label: '个人中心',
      ),
    ];
    BottomNavigationBarItem currentItem = defaultBarItem[_currentIndex];
    if (_currentIndex == 0) {
      currentItem = BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedScroll,
          color: Colors.deepOrange,
        ),
        //icon: Icon(Icons.file_copy_outlined, size: 30),
        label: '音频文件',
      );
    } else if (_currentIndex == 1) {
      currentItem = BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedAddCircle,
          color: Colors.deepOrange,
          size: 30,
        ),
        label: '更多',
      );
    } else if (_currentIndex == 2) {
      currentItem = BottomNavigationBarItem(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedUserCircle,
          color: Colors.deepOrange,
        ),
        label: '个人中心',
      );
    }
    defaultBarItem[_currentIndex] = currentItem;
    return defaultBarItem;
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _showBottomSheet();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: _changeBarItem(),
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrange,
        // 选中时的颜色,
        enableFeedback: false,
      ),
    );
  }

  /**
   * 二级菜单，更多功能往这里添加
   * 点击更多弹出底部菜单窗口
   */
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        elevation: 1,
        builder: (BuildContext context) => Container(
              alignment: Alignment.center,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
              ),
              child: Column(children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          //Get.to(() => RecordPage());
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/recording.png',
                              width: 50,
                              height: 50,
                            ),
                            Text('录音速记'),
                          ],
                        ),
                      ),
                    ),
                    blueController.isConnected.value
                        ? Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Get.to(() => RecordPage());
                              },
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/recording.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  Text('同声传译'),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context); // 关闭底部弹窗
                      },
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancelCircle,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ]),
            ));
  }
}
