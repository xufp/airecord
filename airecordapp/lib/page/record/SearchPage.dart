import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            hintText: '文件名/创建时间/音频来源',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 取消返回主页面
              Navigator.pop(context);
            },
            child: Text(
              '取消',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Center(child: Text('搜索结果展示区')),
    );
  }
}
