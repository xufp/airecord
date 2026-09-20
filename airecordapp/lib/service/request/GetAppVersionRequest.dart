import 'BaseRequest.dart';

class GetAppVersionRequest extends BaseRequest {
  String platform; // 平台
  String? currentVersion; // 当前版本

  GetAppVersionRequest({
    required this.platform,
    this.currentVersion,
  });

  factory GetAppVersionRequest.fromJson(Map<String, dynamic> json) {
    return GetAppVersionRequest(
      platform: json['platform'],
      currentVersion: json['current_version'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['platform'] = platform;
    data['current_version'] = currentVersion;
    return data;
  }
}
