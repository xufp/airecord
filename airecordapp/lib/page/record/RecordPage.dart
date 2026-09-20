import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/page/widget/RecordPenWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFCCDCFF),
        body: blueController.isConnected.value
            ? RecordPenWidget()
            : Container());
  }
}
