import 'package:airecordapp/constant/ErrConstants.dart';

class GetAppVersionResponse {
  int code;
  String msg;
  String? latestVersion;
  String? platform;
  String? downloadUrl;
  String? releaseNotes;
  String? updateTime;
  String? forceUpdate;

  GetAppVersionResponse({
    required this.code,
    required this.msg,
    this.latestVersion,
    this.platform,
    this.downloadUrl,
    this.releaseNotes,
    this.updateTime,
    this.forceUpdate,
  });

  factory GetAppVersionResponse.fromJson(Map<String, dynamic> json) {
    return GetAppVersionResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      latestVersion: json['latest_version'],
      platform: json['platform'],
      downloadUrl: json['download_url'],
      releaseNotes: json['release_notes'],
      updateTime: json['update_time'],
      forceUpdate: json['force_update'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
        'latest_version': latestVersion,
        'platform': platform,
        'download_url': downloadUrl,
        'release_notes': releaseNotes,
        'update_time': updateTime,
        'force_update': forceUpdate,
      };
}
