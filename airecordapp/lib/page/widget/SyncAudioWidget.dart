import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/enum/ImportStateEnum.dart';
import 'package:airecordapp/page/blue/BlueAudioFileList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

/**
 * 转写的文本显示界面
 */
class SyncAudioWidget extends StatefulWidget {
  @override
  State<SyncAudioWidget> createState() => _SyncAudioState();
}

class _SyncAudioState extends State<SyncAudioWidget> with SingleTickerProviderStateMixin {
  final BlueController blueController = Get.find();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return blueController.isConnected.value &&
              !ImportStateEnum.closeSync(blueController.importState.value)
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFFE3F2FD),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFBBDEFB),
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BlueAudioFileList()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sync,
                      size: 16,
                      color: Color(0xFF2196F3),
                    ),
                    SizedBox(width: 8),
                    Text(
                      S.of(context).SyncAudioWidget_k1,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    SpinKitThreeBounce(
                      color: Color(0xFF2196F3),
                      size: 12.0,
                    ),
                    SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_animation.value, 0),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(0xFF2196F3).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.touch_app,
                              size: 16,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : Container();
    });
  }
}

