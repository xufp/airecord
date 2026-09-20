import 'dart:async';

import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:airecordapp/logic/MediaSummaryLogic.dart';
import 'package:airecordapp/page/chatgpt/math_markdown.dart';
import 'package:flutter/material.dart';

/// AI总结页面
/// 展示当前转写记录的 AI 总结内容；底部固定一个"重新总结"按钮，
/// 用户点击后走"转写完成后自动总结"的后端通道重新生成总结，结果会落库覆盖原总结。
///
/// 总结生成路径与转写完成后的自动总结完全一致：
///   MediaSummary(recording, mediaId, promptId).mediaSummary
///     -> POST v1/media/summary 提交任务
///     -> 轮询 GET v1/media/summary/status 拉取结果
///   总结结果由 MediaSummary 内部落库，本页仅在回调中刷新 UI。
class SummaryPage extends StatefulWidget {
  final Recording recording;

  /// 总结所用的提示词模板 ID，与 PlayerPage 选中的模板保持一致
  final String promptId;

  const SummaryPage({Key? key, required this.recording, this.promptId = ''})
      : super(key: key);

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  /// 当前展示的总结文本（可被"重新总结"覆盖）
  late String _summaryText;

  /// 重新总结的请求是否进行中，用于禁用按钮、显示 loading
  bool _regenerating = false;

  /// 轮询超时保护定时器，防止后端长时间无结果导致按钮永久 loading
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _summaryText = widget.recording.summaryText;
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  /// 当前要展示的正文（与原 StatelessWidget 行为保持一致）
  String _displayContent(BuildContext context) {
    final transText = widget.recording.transText;
    if (transText.isEmpty) {
      return S.of(context).PlayerPage_k24; // 未找到转写内容，请先提交转写
    }
    if (_summaryText.isEmpty) {
      return S.of(context).PlayerPage_k23; // 音频内容太少，无法总结
    }
    return _summaryText;
  }

  /// 重新触发总结：走"转写完成后自动总结"的后端通道
  /// 提交 v1/media/summary 任务并轮询 v1/media/summary/status，结果由 MediaSummary 内部落库
  Future<void> _regenerateSummary() async {
    if (_regenerating) return;

    // 没有转写内容无法总结
    if (widget.recording.transText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).PlayerPage_k37), // 音频没有转写，请先转写音频再提问。
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 后端总结通道依赖 mediaId，缺失时无法请求
    final int mediaId = widget.recording.mediaId;
    if (mediaId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).SummaryPage_regenerateFailed),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _regenerating = true);

    // 保证结果只处理一次（成功/失败回调与超时保护二者取其一）
    bool handled = false;
    void finish(bool success, String text) {
      if (handled) return;
      handled = true;
      _timeoutTimer?.cancel();
      _timeoutTimer = null;
      if (!mounted) return;
      if (success && text.isNotEmpty) {
        // 总结结果已由 MediaSummary 内部落库，这里同步内存实例并刷新 UI
        widget.recording.summaryText = text;
        setState(() {
          _summaryText = text;
          _regenerating = false;
        });
      } else {
        setState(() => _regenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).SummaryPage_regenerateFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    // 后端最长轮询约 5 分钟(150 * 2s)，超时未回调则复位按钮避免永久 loading
    _timeoutTimer = Timer(
      const Duration(minutes: 5, seconds: 10),
      () => finish(false, ''),
    );

    MediaSummary(widget.recording, mediaId, widget.promptId).mediaSummary(
      summaryCallback: (int code, String msg, String text) {
        finish(code == ErrConstants.SUCCESS_CODE, text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String content = _displayContent(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context).PlayerPage_k39, // AI总结
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        // Column + Expanded(SingleChildScrollView) 让按钮天然固定在底部，不随滚动消失
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: MathMarkdown(
                    data: content,
                    selectable: true,
                    textColor: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  /// 底部固定操作条：仅一个"重新总结"按钮
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
        ),
      ),
      child: SizedBox(
        height: 44,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _regenerating
                    ? [Colors.blue.withOpacity(0.5), Colors.purple.withOpacity(0.5)]
                    : [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: _regenerating
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: _regenerating ? null : _regenerateSummary,
              child: Center(
                child: _regenerating
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            S.of(context).SummaryPage_regenerating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            S.of(context).SummaryPage_regenerate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
