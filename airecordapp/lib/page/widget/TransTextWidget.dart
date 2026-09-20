import 'dart:convert';

import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/util/DateUtil.dart';
import 'package:flutter/material.dart';
import 'package:airecordapp/db/entity/TransText.dart';
import 'dart:async';

/**
 * 转写的文本显示界面
 */
class TransTextWidget extends StatefulWidget {
  String transText = '';

  //BuildContext? _sliverListCtx;

  Function(BuildContext?)? onHit;

  Function(int duration, int index)? textPressed;
  
  Function()? onScrollStart;
  Function()? onScrollEnd;

  int _hitIndexForCtx1 = 0;

  Recording? recording;

  TransTextWidget(
      {required String transText,
      required int hitIndexForCtx1,
      required Function(BuildContext?) onHit,
      required Function(int duration, int index) textPressed,
      required Function() onScrollStart,
      required Function() onScrollEnd,
      Recording? recording,}) {
    this.transText = transText;
    //this._sliverListCtx = sliverListCtx;
    this._hitIndexForCtx1 = hitIndexForCtx1;
    this.onHit = onHit;
    this.textPressed = textPressed;
    this.onScrollStart = onScrollStart;
    this.onScrollEnd = onScrollEnd;
    this.recording = recording;
  }

  @override
  _TransTextState createState() => _TransTextState();
}

class _TransTextState extends State<TransTextWidget> {
  List<TransText> transTextList = [];
  int startTime = 0;
  String _transText = '';
  // 修改防抖变量为单个时间戳
  DateTime _lastTapTime = DateTime.now();
  ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  Timer? _scrollEndTimer;

  _TransTextState();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _scrollEndTimer?.cancel();
    super.dispose();
  }

  void _handleScroll() {
    if (!_isScrolling) {
      _isScrolling = true;
      widget.onScrollStart?.call();
    }

    // 取消之前的定时器
    _scrollEndTimer?.cancel();
    
    // 设置新的定时器，延迟500ms后触发滚动结束
    _scrollEndTimer = Timer(Duration(milliseconds: 500), () {
      if (_isScrolling) {
        _isScrolling = false;
        widget.onScrollEnd?.call();
      }
    });
  }

  void _initTransText() {
    _transText = widget.transText;
    if (_transText.isNotEmpty) {
      //文本转List
      List<dynamic> textList = jsonDecode(_transText);
      transTextList = textList.map((dynamic e) {
        if (e is Map<String, dynamic>) {
          Map<String, dynamic> map = e;
          return TransText.fromJson(map);
        }
        return TransText(
            index: 0, startTime: 0, endTime: 0, text: 'null', speakId: 0);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    _initTransText();
    if (transTextList.length == 0) {
      //没有转写内容，显示为空
      return SliverToBoxAdapter(
        child: Container(
          alignment: Alignment.center,
          height:  MediaQuery.of(context).size.height/1.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              /*CircularProgressIndicator(
                strokeWidth: 1.0,
              ),*/
              Text(
                '',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFABADC0),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => _listBuilder(context, index),
          childCount: transTextList.length,
        ),
      ),
    );
  }

  String formatMilliseconds(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (index == 0) {
      startTime = transTextList[index].startTime;
    }
    int displayTime = transTextList[index].startTime - startTime;
    String displayTimeStr = formatMilliseconds(displayTime);
    if (widget.onHit != null) {
      widget.onHit!(context);
    }
    
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_outlined,
                size: 15,
                color: widget._hitIndexForCtx1 == index
                    ? Colors.blue
                    : Color(0xFFABADC0),
              ),
              SizedBox(
                width: 5,
              ),
              SelectableText(
                displayTimeStr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: widget._hitIndexForCtx1 == index
                      ? Colors.blue
                      : Color(0xFFABADC0),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              widget._hitIndexForCtx1 == index
                  ? Icon(
                      Icons.play_circle_outline,
                      size: 15,
                      color: Colors.blue,
                    )
                  : Container(),
            ],
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final now = DateTime.now();
              if ((now.difference(_lastTapTime).inMilliseconds.abs() > 300)) {
                _lastTapTime = now;
                widget.textPressed?.call(transTextList[index].startTime, index);
              }
            },
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 17, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: widget._hitIndexForCtx1 == index 
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: AbsorbPointer(
                child: SelectableText(
                  transTextList[index].text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: widget._hitIndexForCtx1 == index
                        ? Colors.blue
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
