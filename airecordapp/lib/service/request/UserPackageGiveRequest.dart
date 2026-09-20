import 'BaseRequest.dart';

/**
 * 服务套餐包领取请求
 */
class UserPackageGiveRequest extends BaseRequest {
  final int packageId;

  UserPackageGiveRequest({required this.packageId});

  factory UserPackageGiveRequest.fromJson(Map<String, dynamic> json) {
    return UserPackageGiveRequest(
      packageId: json['package_id'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
    };
  }
}
