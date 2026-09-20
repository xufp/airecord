import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/db/entity/TransText.dart';
import 'package:flutter/material.dart';

/**
 * 转写的文本显示界面
 */
class SummaryTextWidget extends StatefulWidget {
  String summaryText = '';
  Recording? recording;

  SummaryTextWidget({required String summaryText, Recording? recording}) {
    this.summaryText = summaryText;
    this.recording = recording;
  }

  @override
  _SummaryTextState createState() => _SummaryTextState(recording);
}

class _SummaryTextState extends State<SummaryTextWidget> {
  List<TransText> transTextList = [];
  int startTime = 0;
  String _summaryText = '';
  Recording? recording;

  _SummaryTextState(Recording? recording) {
    this.recording = recording;
  }

  void initState() {
    super.initState();
  }

  void _initSummaryText() {
    _summaryText = widget.summaryText;
  }

  @override
  Widget build(BuildContext context) {
    _initSummaryText();
    if (_summaryText.isEmpty) {
      //没有转写内容，显示为空
      return Container(
        alignment: Alignment.center,
        //height: MediaQuery.of(context).size.height / 1.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '暂未总结',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Color(0xFFABADC0),
              ),
            ),
          ],
        ),
        // 分隔线的颜色
      );
    } else {
      return Container(
        alignment: Alignment.center,
        //margin: EdgeInsets.all(0),
        //height: 1.0, // 分隔线的高度
        //color: Colors.white,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: SelectableText(
                _summaryText, //'How to Transcribe with PLAUD Device?',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
            ),
          ],
        ), // 分隔线的颜色
      );
    }
  }
}
