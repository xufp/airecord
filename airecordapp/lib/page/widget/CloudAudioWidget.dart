import 'package:airecordapp/controller/MediaSyncController.dart';
import 'package:airecordapp/page/record/MediaSyncPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

/**
 * 转写的文本显示界面
 */
class CloudAudioWidget extends StatefulWidget {
  @override
  State<CloudAudioWidget> createState() => _CloudAudioWidgetState();
}

class _CloudAudioWidgetState extends State<CloudAudioWidget> {
  final MediaSyncController mediaSyncController = Get.find();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return mediaSyncController.isSyncing.value
          ? Container(
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MediaSyncPage()));
                },
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      // 使用AnimatedSwitcher来做动画切换效果
                      duration: Duration(seconds: 10), // 动画持续时间
                      transitionBuilder: (child, animation) {
                        // 自定义动画效果
                        return FadeTransition(
                            child: child, opacity: animation); // 使用淡入淡出效果
                      },
                      child: Text(
                        S.of(context).CloudAudioWidget_k1,
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                    SpinKitThreeBounce(
                      color: Colors.green, // 你可以自定义颜色
                      size: 14.0, // 你可以自定义大小
                    )
                  ],
                ),
              ))
          : Container();
    });
  }
}
