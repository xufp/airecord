import '../../constant/ErrConstants.dart';

class GetCodeResponse {
  final int code;
  final String msg;

  GetCodeResponse({
    required this.code,
    required this.msg,
  });

  factory GetCodeResponse.fromJson(Map<String, dynamic> json) {
    return GetCodeResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (code != null) 'code': code,
      if (msg != null) 'msg': msg,
    };
  }
}
