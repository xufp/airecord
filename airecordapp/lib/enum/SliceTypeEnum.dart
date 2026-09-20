/**
 * 转写结果类型
 */
enum SliceTypeEnum {
  IDENTIFY_DOING(1, '一段话识别中，返回不稳定结果'),
  IDENTIFY_COMPLETED(2, '一段话识别完成，返回该段稳定结果'),
  ;

  final int type;
  final String desc;

  const SliceTypeEnum(this.type, this.desc);
}
