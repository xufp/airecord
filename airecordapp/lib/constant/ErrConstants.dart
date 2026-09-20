class ErrConstants {
  // 成功状态码
  static const int SUCCESS_CODE = 200;
  // 成功默认返回提示信息
  static const String SUCCESS_MSG = '成功';
  // socket成功状态码
  static const int SUCCESS_SOCKET_CODE = 0;
  // 异常状态码
  static const int ERR_CODE = -1;
  // 异常信息
  static const String ERR_MSG = '接口调用异常';

  // 异常信息
  static const int REPEAT_UPLOAD_CODE = 10040;

  //文件太短
  static const int OUT_RANGE_DURATION = 10001104;

  //音频文件不支持转写
  static const int MEDIA_NOT_SUPPORT_CONVERT = 10001401;

  static const int MEDIA_SUMMARY_NOT_FOUND_CODE = 10001105;

  static const int MEDIA_TRANSFER_NOT_FOUND_CODE = 10001105;

  static const int MEDIA_SUMMARY_TOO_SHORT_CODE = 10001410; // text is too short to summarize

  //音频文件不存在
  static const int MEDIA_NOT_FOUND_CODE = -1001;
  //音频文件未上传
  static const int MEDIA_NOT_UPLOAD_CODE = -1002;
  //音频文件已转写
  static const int MEDIA_IS_TRANSFER_CODE = -1003;
  //音频文件已总结
  static const int MEDIA_IS_SUMMARY_CODE = -1004;
  //音频文件转写中
  static const int MEDIA_TRANSFERING_CODE = -1005;
  //音频文件未转写
  static const int MEDIA_NOT_TRANSFER_CODE = -1006;
  //音频文件总结中
  static const int MEDIA_SUMMARYING_CODE = -1007;

}
