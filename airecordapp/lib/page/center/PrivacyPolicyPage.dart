import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/logic/LoadConfigLogic.dart';
import 'package:airecordapp/page/chatgpt/math_markdown.dart';
import 'package:airecordapp/service/response/GetPrivacyPolicyResponse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  State<PrivacyPolicyPage> createState() => PrivacyPolicyPageState();
}

class PrivacyPolicyPageState extends State<PrivacyPolicyPage> {

  String content = '';

  @override
  void initState() {
    super.initState();
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initContent(BuildContext _context) async{
    LoadConfigLogic loadConfigLogic = LoadConfigLogic(_context);
    GetPrivacyPolicyResponse privacyPolicyResponse = await loadConfigLogic.getPrivacyPolicy();
    if(privacyPolicyResponse != null && privacyPolicyResponse.code == ErrConstants.SUCCESS_CODE && privacyPolicyResponse.content != null) {
      setState(() {
        content = privacyPolicyResponse.content!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initContent(context);
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: AppBar(
              automaticallyImplyLeading: true,
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(
                S.of(context).PrivacyPolicyPage_k1,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconTheme: IconThemeData(
                color: Color(0xFF666666),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Markdown(
          data: content ?? '',
          selectable: true,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
