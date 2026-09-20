import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/service/response/MediaConvertRecord.dart';

class MediaConvertRecordsResponse {
  int code;
  String msg;
  List<MediaConvertRecord>? data;
  int page;
  int size;
  int total;

  MediaConvertRecordsResponse({
    required this.code,
    required this.msg,
    required this.data,
    required this.page,
    required this.size,
    required this.total
  });

  factory MediaConvertRecordsResponse.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    List<MediaConvertRecord> mediaConvertRecordList = [];
    if(data != null && data.isNotEmpty) {
      List<dynamic>  dataList= data;
      dataList.forEach((element){
        if(element is Map<String, dynamic>) {
          Map<String, dynamic> map = element;
          int mediaId = map['media_id'];
          String mediaName = map['media_name'];
          String recTime = map['rec_time'];
          int duration = map['duration'];
          bool deleted = map['deleted'];
          MediaConvertRecord mediaConvertRecord = MediaConvertRecord(mediaId: mediaId, mediaName: mediaName, recTime: recTime, duration: duration, deleted: deleted);
          mediaConvertRecordList.add(mediaConvertRecord);
        }
      });
    }
    return MediaConvertRecordsResponse(
      code: json['code'] ?? ErrConstants.SUCCESS_CODE,
      msg: json['msg'] ?? ErrConstants.SUCCESS_MSG,
      data: mediaConvertRecordList,
      page: json['page'] == null ? 0 : json['page'],
      size: json['size'] == null ? 0 : json['size'],
      total: json['total'] == null ? 0 : json['total'],
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
      };
}
