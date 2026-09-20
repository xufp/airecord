/**
 * 提示词模板
 */
class PromptTemplates  {
  String promptId;
  String promptDesc;

  PromptTemplates({
    required this.promptId,
    required this.promptDesc,
  });

  factory PromptTemplates.fromJson(Map<String, dynamic> json) {
    return PromptTemplates(
      promptId: json['prompt_id'],
      promptDesc: json['prompt_desc'],
    );
  }

  Map<String, dynamic> toJson() => {
        'prompt_id': promptId,
        'prompt_desc': promptDesc,
      };
}
