import 'package:airecordapp/constant/ErrConstants.dart';

class DeleteAccountResponse {
  final int code;
  final String msg;

  DeleteAccountResponse({
    required this.code,
    required this.msg,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
    };
  }
}
