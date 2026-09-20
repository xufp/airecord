import 'package:airecordapp/page/record/SearchPage.dart';
import 'package:airecordapp/page/record/SelectAllPage.dart';
import 'package:flutter/material.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class RecordBatchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 第一个元素：加粗的文字
                  Text(
                    S.of(context).RecordBatchWidget_k1,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  // 第二个元素：靠右的搜索图标
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 10), // 元素间间隔10
                      IconButton(
                        icon: Icon(Icons.list),
                        onPressed: () {
                          // 打开全选页面
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectAllPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Divider(),
            ],
          ),
        ));
  }
}
