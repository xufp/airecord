import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/response/Link.dart';
import 'package:airecordapp/service/response/MediaConvertRecord.dart';
import 'package:airecordapp/service/response/PackageRecord.dart';

class CreateOrderResponse {
  int code;
  String msg;
  String? orderId;
  int? state;
  Link? link;

  CreateOrderResponse({
    required this.code,
    required this.msg,
    this.orderId,
    this.state,
    this.link,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    var link = json['link'];
    Link linkObj = Link(method: '', href: '');
    if (link is Map<String, dynamic>) {
      Map<String, dynamic> map = link;
      linkObj = Link(method: map['method'], href: map['href']);
    }
    return CreateOrderResponse(
        code: json['code'] ?? ErrConstants.SUCCESS_CODE,
        msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
        orderId: json['order_id'],
        state: json['state'],
        link: linkObj);
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
      };
}
