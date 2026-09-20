class MediaResponse {
  int? code;
  String? msg;
  int? mediaId;
  Result? result;

  MediaResponse({this.code, this.msg, this.mediaId, this.result});

  // 工厂方法: 从JSON数据创建MediaResponse对象
  factory MediaResponse.fromJson(Map<String, dynamic> json) {
    return MediaResponse(
      code: json['code'],
      msg: json['msg'],
      mediaId: json['media_id'],
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }

  // 成员方法: 将MediaResponse对象转成JSON数据
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['media_id'] = this.mediaId;
    if (this.result != null) {
      data['result'] = this.result?.toJson();
    }
    return data;
  }
}

class Result {
  int? sliceType;
  int? index;
  int? startTime;
  int? endTime;
  String? text;

  Result({this.sliceType, this.index, this.startTime, this.endTime, this.text});

  // 工厂方法: 从JSON数据创建Result对象
  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      sliceType: json['slice_type'],
      index: json['index'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      text: json['text'],
    );
  }

  // 成员方法: 将Result对象转成JSON数据
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['slice_type'] = this.sliceType;
    data['index'] = this.index;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['text'] = this.text;
    return data;
  }
}