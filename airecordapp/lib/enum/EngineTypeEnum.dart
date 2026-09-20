/**
 * 转写语言分类
 */
enum EngineTypeEnum {
  ZH('16k_zh', '中文转写类型'),
  EN('16k_en', '英文转写类型'),
  MULTI_LANG('16k_multi_lang', '多语种大模型引擎'),
  ;
  final String type;
  final String desc;

  const EngineTypeEnum(this.type, this.desc);
}