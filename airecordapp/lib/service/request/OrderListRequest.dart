import 'BaseRequest.dart';

class OrderListRequest extends BaseRequest {
  int page; // 页码
  int size; // 页大小
  String states;

  OrderListRequest({
    required this.page,
    required this.size,
    required this.states,
  });

  factory OrderListRequest.fromJson(Map<String, dynamic> json) {
    return OrderListRequest(
      page: json['page'] as int,
      size: json['size'] as int,
      states: json['states'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['size'] = size;
    data['states'] = states;
    return data;
  }
}
