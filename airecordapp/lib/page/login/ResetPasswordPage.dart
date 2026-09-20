import 'package:airecordapp/logic/LoginLogic.dart';
import 'package:flutter/material.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';
import 'dart:async';

/**
 * 重置密码页
 */
class ResetPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ResetPasswordPageState();
  }
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _verifyCodeController = TextEditingController();
  LoginLogic _loginLogic = LoginLogic();

  bool _obscureTextPassword = true; //初始状态为隐藏密码
  bool _obscureTextConfirmPassword = true; //初始状态为隐藏密码
  bool _validate = false; //是否校验通过
  bool _isSubmitting = false; //是否正在提交
  bool _isSendingCode = false; //是否正在发送验证码
  //置灰：发送中倒计时和邮箱框校验不通过，置黑：邮箱校验通过
  bool _disableVerifyCode = true; //是否正在发送
  String _errorMsg = "";
  Timer? _timer;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword; // 切换密码显示状态
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureTextConfirmPassword = !_obscureTextConfirmPassword; // 切换密码显示状态
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  /**
   * 表单校验逻辑
   */
  void _validateInputs() {
    String _emailText = _emailController.text;
    String? _emailValidatorResult = _emailValidator(_emailText);
    if (_emailValidatorResult != null) {
      //邮箱校验不通过
      setState(() {
        _validate = false;
        _errorMsg = _emailValidatorResult;
        _disableVerifyCode = true; //获取验证码置灰
      });
      return;
    } else {
      setState(() {
        _disableVerifyCode = false;
        _errorMsg = '';
      });
    }
    String _verifyCodeText = _verifyCodeController.text;
    if (_verifyCodeText.isEmpty) {
      //验证码不通过
      setState(() {
        _validate = false;
        _errorMsg = S.of(context).ResetPasswordPage_verifyCode_empty;
      });
      return;
    } else {
      setState(() {
        _errorMsg = '';
      });
    }

    String _passworText = _passwordController.text;
    String? _passwordValidatorResult = _passwordValidator(_passworText);
    if (_passwordValidatorResult != null) {
      //密码验证不通过
      setState(() {
        _validate = false;
        _errorMsg = _passwordValidatorResult;
      });
      return;
    } else {
      setState(() {
        _errorMsg = '';
      });
    }

    String _confirmPassworText = _confirmPasswordController.text;
    String? _confirmPasswordValidatorResult =
        _confirmPasswordValidator(_confirmPassworText);
    if (_confirmPasswordValidatorResult != null) {
      //验证码不通过
      setState(() {
        _validate = false;
        _errorMsg = _confirmPasswordValidatorResult;
      });
      return;
    } else {
      if (_passworText != _confirmPassworText) {
        setState(() {
          _validate = false;
          _errorMsg = S.of(context).ResetPasswordPage_password_error;
        });
        return;
      } else {
        setState(() {
          _errorMsg = '';
        });
      }
    }
    //所有校验通过后，可以点击确定按钮
    setState(() {
      _validate = true;
      _errorMsg = '';
    });
  }

  /**
   * 校验邮箱
   */
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).EmailLoginPage_email_empty_error;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      // 邮箱格式不正确
      return S.of(context).EmailLoginPage_email_format_error;
    }
    return null;
  }

  /**
   * 校验密码
   */
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).EmailLoginPage_password_empty_error;
    } else if (value.length < 8 || value.length > 16) {
      //长度为6～16位
      return S.of(context).EmailLoginPage_password_format_error;
    }
    return null;
  }

  /**
   * 校验确认密码
   */
  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).ResetPasswordPage_confirm_password_empty_error;
    } else if (value.length < 8 || value.length > 16) {
      //长度为6～16位
      return S.of(context).ResetPasswordPage_confirm_password_format_error;
    }
    return null;
  }

  //倒计时
  int _start = 120;
  bool _showTime = false;

  void _countdown() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _disableVerifyCode = false;
          _showTime = false;
        });
        _start = 120;
      } else {
        setState(() {
          _start--;
          _showTime = true;
        });
      }
    });
  }

  /**
   * 发送验证码
   */
  void _sendVerifyCode() {
    if (_showTime || _isSendingCode) {
      return;
    }
    String _emailText = _emailController.text;
    String? _emailValidatorResult = _emailValidator(_emailText);
    if (_emailValidatorResult != null) {
      setState(() {
        _validate = false;
        _errorMsg = _emailValidatorResult;
        _disableVerifyCode = true;
      });
      return;
    } else {
      setState(() {
        _isSendingCode = true;
      });
      _loginLogic.sendCodeByResetPassword(context, _emailText)
          .timeout(Duration(seconds: 15), onTimeout: () => null)
          .then((value) {
        if (!mounted) return;
        setState(() {
          _isSendingCode = false;
        });
        if (value == null) {
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_network_error;
          });
        } else if (value.code == 10001123) {
          setState(() {
            _errorMsg = S.of(context).ResetPasswordPage_user_not_found;
          });
        } else if (value.code == 200) {
          setState(() {
            _showTime = true;
            _disableVerifyCode = true;
            _errorMsg = S.of(context).ResetPasswordPage_verifyCode_send_success;
          });
          _countdown();
        } else {
          setState(() {
            _validate = false;
            _errorMsg = S.of(context).ResetPasswordPage_verifyCode_send_error;
          });
        }
      }).catchError((e) {
        if (!mounted) return;
        setState(() {
          _isSendingCode = false;
          _errorMsg = S.of(context).EmailLoginPage_network_error;
        });
      });
    }
  }

  /**
   * 提交表单
   */
  void _commitForm() {
    if (_validate && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });

      String _email = _emailController.text;
      String _verifyCode = _verifyCodeController.text;
      String _password = _passwordController.text;

      _loginLogic
          .resetPassword(context, _email, _password, _verifyCode)
          .timeout(Duration(seconds: 15), onTimeout: () => null)
          .then((value) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
        if (value == null) {
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_network_error;
          });
        } else if (value.code == 10001105) {
          setState(() {
            _errorMsg = S.of(context).EmailLoginPage_network_error;
          });
        } else if (value.code == 200) {
          showDialog(
              context: context,
              builder: (alertContext) {
                AlertDialog alertDialog = AlertDialog(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  alignment: Alignment.center,
                  content: Text(
                    S.of(context).ResetPasswordPage_success,
                    style: TextStyle(color: Colors.white),
                  ),
                );
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.of(alertContext).pop();
                });
                return alertDialog;
              });
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pushNamed('/home');
          });
        } else {
          setState(() {
            _errorMsg = S.of(context).ResetPasswordPage_commit_error;
          });
        }
      }).catchError((e) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _errorMsg = S.of(context).EmailLoginPage_network_error;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 背景装饰
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFE8E5FF),
                  Color(0xFFE5F1FF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.2, 0.6, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6C63FF).withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -60,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4CAF50).withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 主要内容
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部导航栏
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFE5E5E5),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios, size: 18),
                            color: Color(0xFF1A1A1A),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          S.of(context).ResetPasswordPage_k1,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    
                    // 欢迎文本
                    Text(
                      S.of(context).ResetPasswordPage_k1,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      S.of(context).ResetPasswordPage_k2,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 40),
                    
                    // 表单
                    Form(
                      key: _formKey,
                      onChanged: _validateInputs,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hintText: S.of(context).RegisterPage_email_address,
                            icon: Icons.email_outlined,
                            validator: _emailValidator,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            controller: _verifyCodeController,
                            hintText: S.of(context).RegisterPage_verification_code,
                            icon: Icons.lock_outline,
                            suffixIcon: _buildVerifyCodeButton(),
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: S.of(context).RegisterPage_password,
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: _passwordValidator,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hintText: S.of(context).RegisterPage_verify_password,
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: _confirmPasswordValidator,
                          ),
                          if (_errorMsg.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                _errorMsg,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          SizedBox(height: 24),
                          
                          // 确认按钮
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: (_validate && !_isSubmitting) ? [
                                BoxShadow(
                                  color: Color(0xFF6C63FF).withOpacity(0.3),
                                  offset: Offset(0, 4),
                                  blurRadius: 12,
                                ),
                              ] : [],
                            ),
                            child: ElevatedButton(
                              onPressed: (_validate && !_isSubmitting) ? _commitForm : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (_validate && !_isSubmitting) ? Color(0xFF6C63FF) : Color(0xFFE5E5E5),
                                foregroundColor: (_validate && !_isSubmitting) ? Colors.white : Color(0xFF666666),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF666666)),
                                      ),
                                    )
                                  : Text(
                                      S.of(context).ResetPasswordPage_form_commit,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        cursorColor: Color(0xFF6C63FF),
        obscureText: isPassword ? (isPassword ? _obscureTextPassword : _obscureTextConfirmPassword) : false,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color(0xFF9BA0B3),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Color(0xFF9BA0B3),
            size: 20,
          ),
          suffixIcon: suffixIcon ?? (isPassword
              ? IconButton(
                  icon: Icon(
                    isPassword ? (_obscureTextPassword ? Icons.visibility_off : Icons.visibility)
                        : (_obscureTextConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    color: Color(0xFF9BA0B3),
                    size: 20,
                  ),
                  onPressed: isPassword ? _togglePasswordVisibility : _toggleConfirmPasswordVisibility,
                )
              : null),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildVerifyCodeButton() {
    bool _disabled = _disableVerifyCode || _showTime || _isSendingCode;
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: _disabled ? null : _sendVerifyCode,
        style: TextButton.styleFrom(
          backgroundColor: _disabled
              ? Color(0xFFE5E5E5)
              : Color(0xFF6C63FF),
          foregroundColor: _disabled
              ? Color(0xFF666666)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: _isSendingCode
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF666666)),
                ),
              )
            : Text(
                _showTime ? '$_start'+ S.of(context).ResetPasswordPage_k3 : S.of(context).RegisterPage_send_verifycode,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
