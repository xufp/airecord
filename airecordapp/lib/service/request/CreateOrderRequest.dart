import 'BaseRequest.dart';

class CreateOrderRequest extends BaseRequest {
  int packageId; // 套餐ID
  int payChannel; // 支付渠道 1-paypal

  CreateOrderRequest({
    required this.packageId,
    required this.payChannel,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) {
    return CreateOrderRequest(
      packageId: json['package_id'] as int,
      payChannel: json['pay_channel'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['package_id'] = packageId;
    data['pay_channel'] = payChannel;
    return data;
  }
}
