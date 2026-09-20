import 'package:flutter/material.dart';
import 'package:airecordapp/logic/LoadConfigLogic.dart';
import 'package:airecordapp/service/response/GetHelpManualsResponse.dart';
import 'package:airecordapp/service/response/QuestionAnswer.dart';
import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:flutter/services.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class HelperPage extends StatefulWidget {
  @override
  State<HelperPage> createState() => HelperPageState();
}

class HelperPageState extends State<HelperPage> {
  List<QuestionAnswer> helpManuals = [];
  int? expandedIndex; // 当前展开的问题索引

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
    _loadHelpManuals();
  }

  void _loadHelpManuals() async {
    LoadConfigLogic loadConfigLogic = LoadConfigLogic(context);
    GetHelpManualsResponse response = await loadConfigLogic.getHelpManuals();
    if (response.code == ErrConstants.SUCCESS_CODE && response.data != null) {
      setState(() {
        helpManuals = response.data!;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                S.of(context).HelperPage_k1,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              iconTheme: IconThemeData(
                color: Color(0xFF666666),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Container(
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
            child: Column(
              children: List.generate(
                helpManuals.length,
                (index) => Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          expandedIndex = expandedIndex == index ? null : index;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF6C63FF).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6C63FF),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      helpManuals[index].question,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              expandedIndex == index 
                                ? Icons.keyboard_arrow_up 
                                : Icons.keyboard_arrow_down,
                              color: Color(0xFF666666),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (expandedIndex == index)
                      Container(
                        padding: EdgeInsets.fromLTRB(52, 0, 16, 16),
                        child: Text(
                          helpManuals[index].answer,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            height: 1.6,
                          ),
                        ),
                      ),
                    if (index < helpManuals.length - 1)
                      Divider(
                        height: 1,
                        color: Color(0xFFF5F5F5),
                        indent: 52,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
