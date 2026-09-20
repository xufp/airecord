import '../../constant/ErrConstants.dart';

class ApiResponse {
  int? code = ErrConstants.ERR_CODE;
  String? msg = ErrConstants.ERR_MSG;

  ApiResponse({
    this.code,
    this.msg,
  });

  errResponse({int? errCode, String? errMsg}) {
    return ApiResponse(code: ErrConstants.ERR_CODE, msg: ErrConstants.ERR_MSG);
  }
}
