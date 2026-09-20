import 'package:flutter/material.dart';

class SelectAllPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('多选页面'),
      ),
      body: Center(child: Text('这里是选中多个录音操作')),
    );
  }
}
