import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/response/Link.dart';
import 'package:airecordapp/service/response/MediaConvertRecord.dart';
import 'package:airecordapp/service/response/PackageRecord.dart';

class OrderDetailResponse {
  int code;
  String msg;
  String? orderId;
  int? amount;
  String? currency;
  String? payTime;
  int? payChannel;
  String? packageName;
  int? state;

  OrderDetailResponse({
    required this.code,
    required this.msg,
     this.orderId,
     this.amount,
     this.currency,
     this.payTime,
     this.payChannel,
     this.packageName,
     this.state,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      orderId: json['order_id'],
      amount: json['amount'],
      currency: json['currency'],
      payTime: json['pay_time'],
      payChannel: json['pay_channel'],
      packageName: json['package_name'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        'pay_time': payTime,
        'pay_channel': payChannel,
        'package_name': packageName,
        'state': state,
      };
}
