class MediaConvertRecord {
  int mediaId;
  String mediaName;
  String recTime;
  int duration;
  bool deleted;

  MediaConvertRecord(
      {required this.mediaId,
      required this.mediaName,
      required this.recTime,
      required this.duration,
      required this.deleted});

  factory MediaConvertRecord.fromJson(Map<String, dynamic> json) {
    return MediaConvertRecord(
      mediaId: json['meida_id'],
      mediaName: json['media_name'],
      recTime: json['rec_time'],
      duration: json['duration'],
      deleted: json['deleted'],
    );
  }

  Map<String, dynamic> toJson() => {
        'meida_id': mediaId,
        'media_name': mediaName,
        'rec_time': recTime,
        'duration': duration,
        'deleted': deleted,
      };
}
