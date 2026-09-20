import 'dart:convert';

import 'package:airecordapp/constant/CommonConstants.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:airecordapp/page/chatgpt/chatgpt_service.dart';
import 'package:airecordapp/page/chatgpt/math_markdown.dart';
import 'package:flutter/material.dart';

/// 问一问页面
/// 基于当前转写记录与 AI 进行多轮问答
class AskAiPage extends StatefulWidget {
  final Recording recording;

  const AskAiPage({Key? key, required this.recording}) : super(key: key);

  @override
  State<AskAiPage> createState() => _AskAiPageState();
}

class _AskAiPageState extends State<AskAiPage> {
  final ChatGPTService _chatGPTService = ChatGPTService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];
  String _transTextNoTime = '';
  String _dialogSelectedValue = CommonConstants.selectDialog[0];

  @override
  void initState() {
    super.initState();
    _buildTransTextNoTime();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 解析转写 JSON，拼出无时间戳的完整文本，作为对音频提问时的上下文
  void _buildTransTextNoTime() {
    final transText = widget.recording.transText;
    if (transText.isEmpty) return;
    try {
      final List<dynamic> textList = jsonDecode(transText);
      String buffer = '';
      for (final dynamic e in textList) {
        if (e is Map<String, dynamic> && e['text'] != null) {
          buffer += e['text'].toString() + '\n';
        }
      }
      _transTextNoTime = buffer;
    } catch (_) {
      _transTextNoTime = '';
    }
  }

  /// 推荐 prompt 文案的国际化映射（按 `CommonConstants.promptList` 顺序对应）
  String _localizedPrompt(BuildContext context, int index) {
    final s = S.of(context);
    switch (index) {
      case 0:
        return s.AskAiPage_promptSummary;
      case 1:
        return s.AskAiPage_promptTodo;
      case 2:
        return s.AskAiPage_promptMinutes;
      case 3:
        return s.AskAiPage_promptHighlight;
      default:
        return CommonConstants.promptList[index];
    }
  }

  /// 对话模式 chip 文案的国际化映射
  /// 注意：`CommonConstants.selectDialog` 作为内部枚举键保持不变（用于等值判断），
  /// 此处仅做 UI 显示文案映射。
  String _localizedDialogLabel(BuildContext context, String value) {
    final s = S.of(context);
    if (value == CommonConstants.selectDialog[0]) {
      return s.AskAiPage_dialogAudio;
    }
    if (value == CommonConstants.selectDialog[1]) {
      return s.AskAiPage_dialogGeneral;
    }
    return value;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage(String message) async {
    String userMessage = message;
    if (userMessage.isEmpty) {
      userMessage = _controller.text.trim();
    }
    if (userMessage.isEmpty) return;

    final String displayContent = userMessage;
    String requestMessage = userMessage;

    // 对音频提问时，把转写文本拼到提问前面作为上下文
    if (_dialogSelectedValue == CommonConstants.selectDialog[0] &&
        _transTextNoTime.isNotEmpty) {
      requestMessage = _transTextNoTime + '\n' + userMessage;
    }

    setState(() {
      _messages.add({'role': 'user', 'content': displayContent});
      _scrollToBottom();
    });
    _controller.clear();

    if (_dialogSelectedValue == CommonConstants.selectDialog[0] &&
        _transTextNoTime.isEmpty) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': S.of(context).PlayerPage_k37,
        });
        _scrollToBottom();
      });
      return;
    }

    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': S.of(context).PlayerPage_k38,
      });
      _scrollToBottom();
    });

    final gptResponse = await _chatGPTService.sendMessageOK(requestMessage);
    if (!mounted) return;
    setState(() {
      if (_messages.isNotEmpty) _messages.removeLast();
      _messages.add({'role': 'assistant', 'content': gptResponse});
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 由 Scaffold 自动处理键盘弹起，避免手工 viewInsets 造成双重补偿
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context).PlayerPage_k40, // 问一问
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // 点击聊天区任意空白处收起键盘
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView.builder(
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: _messages.length + 5,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          S.of(context).PlayerPage_k22,
                          style: TextStyle(
                              color: Colors.black54, fontSize: 14),
                        ),
                      );
                    }
                    if (index < 5) {
                      final promptIndex = index - 1;
                      if (promptIndex >= CommonConstants.promptList.length) {
                        return SizedBox.shrink();
                      }
                      final String promptText =
                          _localizedPrompt(context, promptIndex);
                      return Container(
                        alignment: Alignment.center,
                        child: Column(children: [
                          InkWell(
                            onTap: () {
                              _sendMessage(promptText);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F5F7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Color(0xFFE5E5EA),
                                  width: 0.5,
                                ),
                              ),
                              padding: EdgeInsets.all(8),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          CommonConstants
                                              .promptIconList[promptIndex],
                                          width: 24,
                                          height: 24,
                                        ),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            promptText,
                                            softWrap: true,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      );
                    }
                    final message = _messages[index - 5];
                    final isUser = message['role'] == 'user';
                    return Container(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUser
                              ? Color(0xFFE3F2FD)
                              : Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color(0xFFE5E5EA),
                            width: 0.5,
                          ),
                        ),
                        padding: EdgeInsets.all(12),
                        child: MathMarkdown(
                          data: message['content'] ?? '',
                          selectable: true,
                          textColor: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // 底部输入栏：上方一根分隔线，与聊天区区分
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                ),
              ),
              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 输入框：minLines=1, maxLines=5，超出 5 行内部滚动
                  TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(
                      color: Colors.black,
                      height: 1.4,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: S.of(context).PlayerPage_k41,
                      hintStyle: TextStyle(
                        color: Colors.black38,
                        fontSize: 16,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: Color(0xFFF5F5F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Color(0xFFE5E5EA),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.blue.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  // chip 切换 + 发送按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: CommonConstants.selectDialog
                              .map((String value) {
                            final bool isSelected =
                                _dialogSelectedValue == value;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _dialogSelectedValue = value;
                                  });
                                },
                                child: Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 4),
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.withOpacity(0.1)
                                        : Color(0xFFF5F5F7),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue.withOpacity(0.5)
                                          : Color(0xFFE5E5EA),
                                      width: 1,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _localizedDialogLabel(context, value),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.black87,
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _sendMessage(''),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              alignment: Alignment.center,
                              height: 32,
                              width: 60,
                              padding: EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/images/send.png',
                                width: 20,
                                height: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
