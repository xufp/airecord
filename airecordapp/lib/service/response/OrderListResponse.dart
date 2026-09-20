import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/response/OrderRecord.dart';

class OrderListResponse {
  int code;
  String msg;
  int page;
  int size;
  int total;
  List<OrderRecord> data;

  OrderListResponse({
    required this.code,
    required this.msg,
    required this.page,
    required this.size,
    required this.total,
    required this.data,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    List<OrderRecord> orderRecordList = [];
    if (data != null && data.isNotEmpty) {
      List<dynamic> dataList = data;
      dataList.forEach((element) {
        if (element is Map<String, dynamic>) {
          Map<String, dynamic> map = element;
          String orderId = map['order_id'];
          int amount = map['amount'];
          String currency = map['currency'];
          String payTime = map['pay_time'];
          int payChannel = map['pay_channel'];
          String packageName = map['package_name'];
          int state = map['state'];
          OrderRecord orderRecord = OrderRecord(
              orderId: orderId,
              amount: amount,
              currency: currency,
              payTime: payTime,
              payChannel: payChannel,
              packageName: packageName,
              state: state);
          orderRecordList.add(orderRecord);
        }
      });
    }

    return OrderListResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      page: json['page'] == null ? 0 : json['page'],
      size: json['size'] == null ? 0 : json['size'],
      total: json['total'] == null ? 0 : json['total'],
      data: orderRecordList,
    );
  }

  /*Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
      };*/
}
