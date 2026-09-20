import 'BaseRequest.dart';

/**
 * 绑定设备请求
 */
class ActivateMemberRequest extends BaseRequest {
  final String cardNo;
  //final String cardPwd;

  ActivateMemberRequest({
    this.cardNo = '',
    //this.cardPwd = '',
  });

  factory ActivateMemberRequest.fromJson(Map<String, dynamic> json) {
    return ActivateMemberRequest(
      cardNo: json['card_code'],
      //cardPwd: json['card_pwd'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'card_code': cardNo,
      //'card_pwd': cardPwd,
    };
  }
}
