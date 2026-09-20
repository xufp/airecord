/**
 * 订单明细
 */
class OrderRecord {
  String orderId;
  int amount;
  String currency;
  String payTime;
  int payChannel;
  String packageName;
  int state;

  OrderRecord({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.payTime,
    required this.payChannel,
    required this.packageName,
    required this.state,
  });

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    return OrderRecord(
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
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        'pay_time': payTime,
        'pay_channel': payChannel,
        'package_name': packageName,
        'state': state,
      };
}
