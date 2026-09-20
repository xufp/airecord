/**
 * 转写的文本内容
 */
class TransText {
  final int index;
  final int startTime;
  final int endTime;
  final String text;
  final int speakId;

  TransText(
      {required this.index,
      required this.startTime,
      required this.endTime,
      required this.text,
      required this.speakId});

  factory TransText.fromJson(Map<String, dynamic> json) {
    return TransText(
        index: json['index'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        text: json['text'],
        speakId: json['speak_id']);
  }
}
