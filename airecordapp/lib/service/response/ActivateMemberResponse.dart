import '../../constant/ErrConstants.dart';

class ActivateMemberResponse {
  final int code;
  final String msg;

  ActivateMemberResponse({
    required this.code,
    required this.msg,
  });

  factory ActivateMemberResponse.fromJson(Map<String, dynamic> json) {
    return ActivateMemberResponse(
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
