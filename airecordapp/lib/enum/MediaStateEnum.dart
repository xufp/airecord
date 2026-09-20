import 'package:flutter/foundation.dart';

/**
 * 音频同步状态
 */
enum MediaStateEnum {
  INIT(0,'初始化状态'), // index = 0
  UPLOADED(1,'已上传'), // index = 1
  TRANSLATED(2,'已转写'), // index = 2
  SUMMARYED(3,'已总结'); // index = 3

  final int state;
  final String desc;

  const MediaStateEnum(this.state, this.desc);
}
