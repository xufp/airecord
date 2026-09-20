import 'package:airecordapp/controller/RecordingController.dart';
import 'package:airecordapp/page/record/OperateFilePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeftDrawer extends StatefulWidget {
  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  RecordingController dataController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: Color(0xFFF3F4F8),
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // 设置圆角半径为8.0
        side: BorderSide(color: Colors.white, width: 1.0),
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF3F4F8),
        appBar: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          title: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 35,
                    width: 100,
                    //color: Colors.grey.withOpacity(0.3),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed('/search');
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            fillColor: Colors.grey[100],
                            filled: true,
                            // 限制错误信息的行数
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                width: 0.0,
                                color: Colors.grey[300]!,
                              ),
                            ),
                            hintText: '在所有文件中搜索',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Color(0xFFF3F4F8),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(children: <Widget>[
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OperateFilePage(),
                      ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/folder_fill.png',
                          width: 18,
                          height: 18,
                          color: Colors.red,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '文件批量处理',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/trash.png',
                        width: 18,
                        height: 18,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '回收站',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),*/
                ]),
              ),
            ),
            // 添加分隔线
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(0),
                height: 1, // 分隔线的高度
                color: Colors.white, // 分隔线的颜色
              ),
            ),
            //排序方式列表
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: Text(
                '排序方式',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              backgroundColor: Color(0xFFF3F4F8),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        dataController.sort('created_at');
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '创建时间',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 5),
                        dataController.sortColumn == 'created_at'
                            ? Image.asset(
                                'assets/images/sort_down.png',
                                width: 18,
                                height: 18,
                                color: Colors.grey,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        dataController.sort('updated_at');
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '修改时间',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 5),
                        dataController.sortColumn == 'updated_at'
                            ? Image.asset(
                                'assets/images/sort_down.png',
                                width: 18,
                                height: 18,
                                color: Colors.grey,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
    // TODO: implement build
  }

  Widget _listBuilder(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(children: <Widget>[
              Image.asset(
                'assets/images/label.png',
                width: 14,
                height: 14,
                color: Colors.blue,
              ),
              SizedBox(width: 5),
              Text(
                dataController.labelList[index].toString(),
                style: TextStyle(fontSize: 14),
              ),
            ]),
            Icon(
              Icons.more_vert_outlined,
              size: 14,
              color: Colors.grey[600],
            ),
          ]),
    );
  }
}
