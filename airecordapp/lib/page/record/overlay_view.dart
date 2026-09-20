import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/**
 * 作废文件，先保留
 */
class OverlayUsePage extends StatefulWidget {
  const OverlayUsePage({super.key});

  @override
  State<OverlayUsePage> createState() => _OverlayUsePageState();
}

class _OverlayUsePageState extends State<OverlayUsePage> {
  /// overlay 状态
  OverlayState? overlayState;
  OverlayEntry? overlayEntry;

  // 随机位置显示层
  void showRandomOverlay(BuildContext context) {
    // 随机颜色
    final bgColor = Colors.black;

    // 弹框的宽度
    final screenWidth = MediaQuery.of(context).size.width / 2;

    // 弹框的高度
    final screenHeight = MediaQuery.of(context).size.height / 3;

    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        // 指定位置
        top: 80,
        right: 20,
        child: Container(
          width: screenWidth,
          height: screenHeight,
          color: bgColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              GestureDetector(
                onTap: () {
                  overlayEntry?.remove();
                  Navigator.pushNamed(context, '/record');
                },
                child: Text(
                  '这是一个测试',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    });
    Overlay.of(context).insert(overlayEntry!);
  }

  // 控制按钮
  /* Widget _buildBtns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 随机新增
        ElevatedButton(
          onPressed: () => showRandomOverlay(context),
          child: const Text("随机新增"),
        ),

        // 关闭所有
        ElevatedButton(
          onPressed: () {
            for (final entry in entriesList) {
              entry.remove();
            }
            entriesList = [];
          },
          child: const Text("关闭所有"),
        ),

        // 随机排序
        ElevatedButton(
          onPressed: () {
            // 从屏幕上移除
            for (final entry in entriesList) {
              entry.remove();
            }

            // 使用Random类创建随机数生成器
            Random random = Random();

            // 使用List的sublist()方法创建一个新列表
            List<OverlayEntry> shuffledEntries = entriesList.sublist(0);

            // 调用List的shuffle()方法，传入一个随机数生成器
            shuffledEntries.shuffle(random);

            // 插入界面
            overlayState?.insertAll(shuffledEntries);
          },
          child: const Text("随机排序"),
        ),
      ],
    );
  }*/

  @override
  void initState() {
    super.initState();
    // 获取 overlay 状态
    overlayState = Overlay.of(context);
  }

  @override
  void dispose() {
    // 销毁
    overlayState?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // 销毁
    overlayState?.deactivate();
    super.deactivate();
  }

  void setState(VoidCallback fn) {}

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showRandomOverlay(context);
        },
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedMenu01,
          color: Colors.deepOrange,
          size: 20,
        ));
/*    Scaffold(
      body:
    );*/
  }
}
