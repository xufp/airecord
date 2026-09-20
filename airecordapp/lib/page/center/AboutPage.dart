import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class AboutPage extends StatefulWidget {
  @override
  State<AboutPage> createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
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
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Stack(
          children: [
            AppBar(
              automaticallyImplyLeading: true, // 隐藏默认的回退键
              backgroundColor: Colors.white,
              centerTitle: true,
              title: Text(
                S.of(context).AboutPage_k1,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PingFang SC-Semibold',
                  color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: ListView(
          children: [
            const SizedBox(height: 8.0),
            _buildContainer(
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textDirection: TextDirection.ltr,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 16.0, top: 16.0, bottom: 4.0, right: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(S.of(context).AboutPage_k2,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'PingFang SC-Semibold',
                                      color: Colors.grey[800]),
                                  textAlign: TextAlign.left),
                              Text(
                                'V2.3.0',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                EdgeInsets.only(bottom: 0.0, left: 0.0, right: 0.0),
                null),
            _buildContainer(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  textDirection: TextDirection.ltr,
                  children: [
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse('https://your-domain.com/download.html');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Container(
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/internet.png',
                                    width: 22,
                                    height: 22,
                                  ),
                                  SizedBox(width: 5),
                                  Text(S.of(context).AboutPage_k3,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'PingFang SC-Semibold',
                                          color: Colors.blue),
                                      textAlign: TextAlign.left),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    /*InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/tradeRecord');
                      },
                      child: Container(
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/yuan.png',
                                    width: 18,
                                    height: 18,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(width: 5),
                                  Text('在X上关注我们',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'PingFang SC-Semibold',
                                        color: Colors.blue,
                                      ),
                                      textAlign: TextAlign.left),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.navigate_next,
                              color: Colors.black,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: Colors.grey[100], thickness: 1),*/

                  ],
                ),
                null,
                null),
            _buildContainer(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  textDirection: TextDirection.ltr,
                  children: [
                    InkWell(
                      onTap: () async {
                        Navigator.of(context).pushNamed('/userAgreement');
                      },
                      child: Container(
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 5),
                                  Text(S.of(context).AboutPage_k7,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'PingFang SC-Semibold',
                                          color: Colors.grey[800]),
                                      textAlign: TextAlign.left),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.navigate_next,
                              color: Colors.black,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: Colors.grey[100], thickness: 1),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed('/privacyPolicy');
                      },
                      child: Container(
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(width: 5),
                                  Text(S.of(context).AboutPage_k8,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'PingFang SC-Semibold',
                                          color: Colors.grey[800]),
                                      textAlign: TextAlign.left),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.navigate_next,
                              color: Colors.black,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                null,
                null),
          ],
        ),
      ),
    );
  }

  /**
   * 构建容器
   * @param widget
   * @return
   */
  Widget _buildContainer(
      Widget widget, EdgeInsetsGeometry? padding, EdgeInsetsGeometry? margin) {
    return Container(
      padding: padding == null
          ? const EdgeInsets.only(
              left: 16.0, top: 4.0, bottom: 4.0, right: 16.0)
          : padding,
      margin: margin == null
          ? EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0)
          : margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
      ),
      child: widget,
    );
  }
}
