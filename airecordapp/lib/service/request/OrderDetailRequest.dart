import 'BaseRequest.dart';

class OrderDetailRequest extends BaseRequest {
  String orderId; // 套餐ID

  OrderDetailRequest({
    required this.orderId,
  });

  factory OrderDetailRequest.fromJson(Map<String, dynamic> json) {
    return OrderDetailRequest(
      orderId: json['order_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    return data;
  }
}
