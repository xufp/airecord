class MediaConvertResetResponse {
  int? code;
  String? msg;

  MediaConvertResetResponse({this.code, this.msg});

  factory MediaConvertResetResponse.fromJson(Map<String, dynamic> json) {
    return MediaConvertResetResponse(
      code: json['code'],
      msg: json['msg'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    return data;
  }
}
