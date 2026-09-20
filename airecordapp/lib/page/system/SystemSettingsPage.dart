import 'package:airecordapp/page/login/EmailLoginPage.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../blue/BluetoothPage.dart';
import 'package:airecordapp/logic/LoginLogic.dart';

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('通用设置',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          //_buildSettingItem('设备名称', context, '/device_name_settings'),
          //_buildSettingItem('固件版本', context, '/firmware_version'),
          //_buildSettingItem('默认录音模式', context, '/default_recording_mode'),
          _buildContainer(
              _buildSettingItem('清除缓存', context, '/space_management'),
              EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0, top: 8.0)),

          _buildContainer(
              _buildSettingItem('使用帮助', context, '/space_management'), null),
          SizedBox(
            height: 30,
          ),
          Container(
            alignment: Alignment.center,
            width: 500,
            //width: 10,
            /*decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
            ),*/
            child: TextButton(
              onPressed: () async {
                bool logout = await LoginLogic.removeAll();
                if (!logout) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('退出异常')),
                  );
                } else {
                  // 取消返回主页面
                  //Navigator.pushNamed(context, '/home');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => EmailLoginPage()),
                    ModalRoute.withName('/home'),
                  );

                }
              },
              child: Text('退出登录',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  )),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(300, 30)),
                overlayColor: MaterialStateProperty.resolveWith(
                  (states) {
                    return states.contains(MaterialState.pressed)
                        ? Colors.transparent
                        : Colors.orangeAccent.withOpacity(0.1); // 设置阴影颜色
                  },
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    side: BorderSide(
                      color: Colors.deepOrange.withOpacity(0.1), // 设置边框颜色
                      width: 0,
                    ),
                  ),
                ),
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                ),
                backgroundColor:
                    MaterialStateProperty.all(Colors.deepOrange), // 设置填充颜色
              ),
            ),
          )
        ],
      ),
    );
  }

  /**
   * 构建容器
   * @param widget
   * @return
   */
  Widget _buildContainer(Widget widget, EdgeInsetsGeometry? margin) {
    return Container(
      padding:
          const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0, right: 16.0),
      margin: margin == null
          ? EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0)
          : margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
      ),
      child: widget,
    );
  }

  ListTile _buildSettingItem(String title, BuildContext context, String route) {
    return ListTile(
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 12,
      ),
      onTap: () {
        // 跳转到详情页面
        Navigator.pushNamed(context, route);
      },
    );
  }
}
