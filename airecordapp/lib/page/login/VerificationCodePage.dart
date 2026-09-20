import 'dart:async';

import 'package:airecordapp/logic/PhoneNumberInputLogic.dart';
import 'package:flutter/material.dart';

import '../../logic/VerificationCodeLogic.dart';

class VerificationCodePage extends StatefulWidget {
  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  String _phoneNumber = '';
  VerificationCodeLogic logic = VerificationCodeLogic();
  PhoneNumberInputLogic phoneNumberInputLogic = PhoneNumberInputLogic();
  bool _isButtonDisabled = true;
  Timer? _timer;
  int _start = 60;
  int countdownTime = 60;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
    _timer?.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _phoneNumber = args?['phoneNumber'];
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
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text('验证码已经发送到手机${_phoneNumber}'),
              ),
              TextFormField(
                controller: _codeController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: '验证码',
                    suffixIcon: Center(
                      widthFactor: 1.0,
                      child: _isButtonDisabled
                          ? Text(
                              '$_start 秒后重新获取',
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
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFEA443),
                  minimumSize: const Size(500, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // 获取文本框输入的内容
                    final String code = _codeController.text.trim();
                    logic.verifyCode(context, _phoneNumber ?? "", code).then((value) {
                      if (value) {
                        // 验证用户验证码登录
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/index', (Route<dynamic> route) => false);
                      }
                    });
                  }
                },
                child: const Text(
                  '登录',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
