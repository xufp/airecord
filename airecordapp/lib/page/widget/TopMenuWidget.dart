import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

/**
 * 暂且废弃，没有地方用，代码保留
 */
class TopMenuWidget extends StatefulWidget {
  @override
  _TopMenuWidgetState createState() => _TopMenuWidgetState();
}

class _TopMenuWidgetState extends State<TopMenuWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  OverlayEntry? _overlayEntry;

  // 定义动画
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0.8).animate(_controller!);
  }

  OverlayEntry? _createOverlayEntry() {
    // 随机颜色
    final bgColor = Colors.black;
    _overlayEntry = OverlayEntry(builder: (context) {
      return Stack(children: [
        Positioned(
          top: 80,
          right: 20,
          child: FadeTransition(
            opacity: _animation!,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: bgColor, // 设置圆角半径
              ),
              child: Column(
                children: [
                  /*SizedBox(
                    height: 10,
                  ),*/
                  GestureDetector(
                    onTap: () {
                      _removeEntry();
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 10,
                        top: 20,
                      ),
                      child: Row(children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedLicense,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('批量转写',
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            )),
                      ]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _removeEntry();
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 10,
                        top: 20,
                      ),
                      child: Row(children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCloudUpload,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '批量保存到云空间',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _removeEntry();
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 10,
                        top: 20,
                      ),
                      child: Row(children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCloudDownload,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('批量从云空间下载',
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            )),
                      ]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _removeEntry();
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 10,
                        top: 20,
                      ),
                      child: Row(children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('批量删除',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.none,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            )),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]);
    });
    //Overlay.of(context).insert(overlayEntry);
    return _overlayEntry;
  }

  OverlayEntry? overlayEntry;

  void _showOverlay() {
    if (overlayEntry == null) {
      overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(overlayEntry!);
    }
    _controller!.forward();
  }

  /*void _hideOverlay() {
    _controller!.reverse().then((_) {
      OverlayEntry overlayEntry = Overlay.of(context).find();
      if (overlayEntry != null) {
        overlayEntry.remove();
      }
    });
  }*/

  void _removeEntry() {
    if (overlayEntry == null) return;
    overlayEntry!.remove();
    overlayEntry = null;
  }

  @override
  void dispose() {
    _removeEntry();
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          _showOverlay();
        },
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedMenu01,
          color: Colors.deepOrange,
          size: 20,
        ));
  }
}
