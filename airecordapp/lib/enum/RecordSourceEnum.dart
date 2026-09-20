/**
 * 录音来源
 */
enum RecordSourceEnum {
  APP('APP', 'APP'),
  PEN('PEN', '录音笔'),
  PEN_V2('PEN_V2', '新款录音笔'),
  IMPORT('IMPORT', '导入'),
  ;

  final String source;
  final String desc;

  const RecordSourceEnum(this.source, this.desc);

  static String getDesc(String source)  {
    if (source == APP.source) {
      return APP.desc;
    } else if (source == PEN.source) {
      return PEN.desc;
    } else if (source == PEN_V2.source) {
      return PEN_V2.desc;
    } else if (source == IMPORT.source) {
      return IMPORT.desc;
    }
    return '';
  }
}