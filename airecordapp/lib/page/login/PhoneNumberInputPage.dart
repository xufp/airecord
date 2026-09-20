import 'package:flutter/material.dart';

import 'package:airecordapp/logic/PhoneNumberInputLogic.dart';
import 'package:airecordapp/logic/VerificationCodeLogic.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class PhoneNumberInputPage extends StatefulWidget {
  @override
  State<PhoneNumberInputPage> createState() => PhoneNumberInputPageState();
}

class PhoneNumberInputPageState extends State<PhoneNumberInputPage> {
  final _formKey = GlobalKey<FormState>(); // 表单键
  final _phoneController = TextEditingController(); // 文本控制器
  final _codeController = TextEditingController();
  String _phoneNumber = '';
  PhoneNumberInputLogic phoneNumberInputLogic = PhoneNumberInputLogic();
  VerificationCodeLogic verificationCodeLogic = VerificationCodeLogic();
  bool _isButtonDisabled = false;
  Timer? _timer;
  int _start = 120;
  int countdownTime = 120;

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose(); // 在页面销毁前释放控制器资源
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    countdown();
  }

  void countdown() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _isButtonDisabled = false;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void startTimer() {
    phoneNumberInputLogic.isSmsCode(context, _phoneNumber);
    setState(() {
      _isButtonDisabled = true;
      _start = countdownTime;
    });
    countdown();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/mainlogo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Container(
                  child: Text(
                    '音悦AI速记',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  alignment: Alignment(-1, 0),
                  width: 250,
                  height: 50,
                  child: TextFormField(
                    controller: _phoneController,
                    // 使用控制器获取文本
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '请输入手机号码',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入手机号';
                      }
                      // 验证手机号输入有效性
                      final RegExp phoneExp = RegExp(
                        r'^(?:[+0]9)?[0-9]{10,12}$',
                      );
                      if (!phoneExp.hasMatch(value)) {
                        return '手机号格式不正确';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _phoneNumber = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment(-1, 0),
                  width: 250,
                  height: 50,
                  child: TextFormField(
                    controller: _codeController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        //labelText: '验证码',
                        hintText: '请输入验证码',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        suffixIcon: Center(
                          widthFactor: 1.0,
                          child: _isButtonDisabled
                              ? Text(
                                  '$_start',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                )
                              : InkWell(
                                  child: Text(
                                    '获取验证码',
                                    style: TextStyle(
                                      color: Color(0xFFFEA443),
                                    ),
                                  ),
                                  onTap: () {
                                    // 点击事件的处理函数
                                    startTimer();
                                  },
                                ),
                        )),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入验证码';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment(-1, 0),
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      //Color(0xFFFEA443),
                      minimumSize: const Size(500, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // 获取文本框输入的内容
                        final String phone = _phoneController.text.trim();
                        final String code = _codeController.text.trim();

                        verificationCodeLogic
                            .verifyCode(context, phone ?? "", code)
                            .then((value) {
                          if (value) {
                            // 验证用户验证码登录
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('登录成功')),
                            );
                            Navigator.pushNamed(context, '/index');
                          } else {
                            // 表单验证失败，显示错误信息
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('验证码错误')),
                            );
                          }
                        });
                      } else {
                        // 表单验证失败，显示错误信息
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('输入内容校验失败')),
                        );
                      }
                    },
                    child: const Text(
                      '登录',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
