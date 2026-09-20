import 'BaseRequest.dart';

class PackageAvailableRequest extends BaseRequest {
  int packageType; //套餐类型 1：免费体验类，2：付费购买套餐， 3：订阅计划

  PackageAvailableRequest({
    required this.packageType,
  });

  factory PackageAvailableRequest.fromJson(Map<String, dynamic> json) {
    return PackageAvailableRequest(
      packageType: json['package_type'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['package_type'] = packageType;
    return data;
  }
}
