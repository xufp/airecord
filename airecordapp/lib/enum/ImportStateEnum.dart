/**
 * 音频文件导入状态
 */
enum ImportStateEnum {
  STATRT_NO_AUDIO(0, '初始无文件传输'),
  START_SEND(1, '开始传输文件'),
  IS_SENDING(2, '正在传输文件'),
  START_DECODE(3, '开始解码文件'),
  DECODE_COMPLETED(4, '文件解码成功'),
  SAVE_COMPLETED(5, '文件存储成功'),
  NEXT_SEND(6, '继续导入下一个文件'),
  ALL_COMPLETED(7, '所有文件导入成功'),
  ;

  final int state;
  final String desc;

  const ImportStateEnum(this.state, this.desc);

  // 创建一个静态方法获取状态文案
  static String getDescriptionByState(int state) {
    for (var value in ImportStateEnum.values) {
      if (value.state == state) {
        return value.desc;
      }
    }
    return '未知状态'; // 如果找不到匹配的状态，返回一个默认说明
  }

  // 是否可以关闭同步音频
  static bool closeSync(int state) {
    return (STATRT_NO_AUDIO.state == state || ALL_COMPLETED.state == state)
        ? true
        : false;
  }
}
