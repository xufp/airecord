class CommonConstants {
  static const int YES = 1; // 是
  static const int NO = 0; // 否
  static const int DELETED = 1; // 已删除
  static const int NOT_DELETED = 0; // 未删除
  static const int UPLOADED = 1; // 已上传
  static const int NOT_UPLOADED = 0; // 未上传
  static const int FAIL_UPLOADED = -1; // 上传失败
  static const int UPLOAD_DEFAULT_COUNT = 0; // 未删除
  static const int OPUS_SAMPLE_RATE = 16000; // opus音频采样率
  static const int OPUS_CHANNELS = 1; // opus音频声道数
  static const int SAMPLE_RATE = 44100; // 音频通用采样率
  static const int CHANNELS = 1; // 音频通道
  static const int PCM_SINK_BUFFER_SIZE = 8192; // pcm录音流每次流大小
  static const int DEFAULT_MEDIA_ID = 0; // 默认media_id
  static const String PEN_SOUCE = 'PEN';
  static const bool isConnected = false; //用于判断是否连接蓝牙才展示菜单
  static const String SITE = 'CN';
  static const List<String> promptList = [
    '帮我总结一下会议的核心要点',
    '请整理一下会议的待办事项',
    '为我书写一份正式规范的会议纪要',
    '请从文中提炼出优秀的精彩的语句'
  ];
  static const List<String> promptIconList = [
    'assets/images/keyword.png',
    'assets/images/todo_list.png',
    'assets/images/meeting_summary.png',
    'assets/images/hotword.png'
  ];

  static const List<Map<String, String>> language1 = [
    {'': ''},
  ];

  static const List<String> language = [
    //'中文(普通话)',
    //'中文(普通话+方言)',
    '中文',
    '英语',
    '日语',
    '韩语',
    '法语',
    '德语',
    '越南语',
    '马来语',
    '印度尼西亚语',
    '菲律宾语',
    '泰语',
    '葡萄牙语',
    '土耳其语',
    '阿拉伯语',
    '西班牙语',
    '印地语',
  ];
  static const List<String> summaryTemplate = [
    '通用总结',
    '会议纪要',
    '课堂笔记',
  ];

  static const List<String> selectDialog = [
    '对音频提问',
    '通用问题',
  ];
}
