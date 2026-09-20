import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:airecordapp/constant/CommonConstants.dart';
import 'package:airecordapp/constant/ErrConstants.dart';
import 'package:airecordapp/db/entity/Recording.dart';
import 'package:airecordapp/db/entity/TransText.dart';
import 'package:airecordapp/enum/MediaStateEnum.dart';
import 'package:airecordapp/logic/LoadConfigLogic.dart';
import 'package:airecordapp/logic/MediaCoreLogic.dart';
import 'package:airecordapp/logic/PackageLogic.dart';
import 'package:airecordapp/logic/RadioLogic.dart';
import 'package:airecordapp/page/widget/BuyRecommendWidget.dart';
import 'package:airecordapp/page/chatgpt/chat_screen.dart';
import 'package:airecordapp/page/chatgpt/chatgpt_service.dart';
import 'package:airecordapp/page/chatgpt/math_markdown.dart';
import 'package:airecordapp/page/record/AskAiPage.dart';
import 'package:airecordapp/page/record/SummaryPage.dart';
import 'package:airecordapp/page/record/WaveBubble.dart';
import 'package:airecordapp/page/widget/TransTextWidget.dart';
import 'package:airecordapp/service/DioService.dart';
import 'package:airecordapp/service/RecordingService.dart';
import 'package:airecordapp/service/response/MediaResponse.dart';
import 'package:airecordapp/service/response/MediaUpdateResponse.dart';
import 'package:airecordapp/service/response/MediaUploadResponse.dart';
import 'package:airecordapp/util/DateUtil.dart';
import 'package:airecordapp/service/response/PromptTemplates.dart';
import 'package:airecordapp/service/response/GetAsrEngineModelsResponse.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';
import 'package:clipboard/clipboard.dart';
import 'package:docx_template/docx_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  Recording? _recording;
  RadioLogic radioLogic = RadioLogic();
  PackageLogic packageLogic = PackageLogic();
  bool _isTransLoading = false;
  MediaUploadResponse? mediaUploadResponse;
  RecordingService recordingService = RecordingService();
  String transText = "";
  bool _isErrTrans = false;
  int mediaId = 0;
  int isTranslated = 0;
  int isSummary = 0;
  String summaryText = "";
  int _hitIndexForCtx1 = 0;
  List<TransText> transTextList = [];
  String transTextNoTime = "";
  bool isTranslatedLoading = false;
  Timer? _statuTimer; // 转写状态计时器
  Duration _timePeriod = const Duration(seconds: 2);
  bool _isAutoScrollEnabled = true; // 添加自动滚动控制标志

  // 添加语言模型和总结模板相关变量
  List<AsrEngineModel> engineModels = [];
  List<PromptTemplates> promptTemplates = [];
  String selectedEngineType = '';
  String selectedTemplateId = '';
  LoadConfigLogic? _loadConfigLogic;

  late SliverObserverController observerController;
  ScrollController scrollController = ScrollController();
  BuildContext? _sliverListCtx;

  GlobalKey<WaveBubbleState> _waveBubbleKey = GlobalKey<WaveBubbleState>();

  TextEditingController? _fileNameEditingController = null;

  final _player = AudioPlayer();
  double _currentSpeed = 1.0; // 添加当前速度变量
  final List<double> _availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0]; // 可选速度列表

  @override
  void initState() {
    super.initState();
    observerController = SliverObserverController(controller: scrollController);
    _startStatuTimer();
    _loadConfigLogic = LoadConfigLogic(context);
    _loadModelsAndTemplates();
    // iOS 平台需要先配置音频会话
    if (Platform.isIOS) {
      _configureAudioSession();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 这里会在 widget 树构建完成后执行
      //_initPlayer();
      _setupStateListener();
    });
  }

  // iOS 音频会话配置
  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth |
        AVAudioSessionCategoryOptions.allowBluetoothA2dp |
        AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      print('iOS Audio Session configured successfully');
    } catch (e) {
      print('Failed to configure iOS Audio Session: $e');
    }
  }

  // 初始化播放器
  void _initPlayer() async{
    //打个日志
    print('_initPlayer: ${_recording!.filePath}');
    if (_recording == null || _recording!.filePath.isEmpty) {
      print('_initPlayer: recording or filePath is null/empty');
      return;
    }

    // 检查文件是否存在
    final file = File(_recording!.filePath);
    if (!file.existsSync()) {
      print('_initPlayer: file does not exist: ${_recording!.filePath}');
      return;
    }

    /*print('_initPlayer: ${_recording!.filePath}');
    try {
      _player.setUrl(_recording!.filePath);
    } catch (e) {
      print('_initPlayer error: $e');
    }*/

    // iOS 平台特殊处理
    if (Platform.isIOS) {
      await _initPlayerForIOS();
    } else {
      await _initPlayerForAndroid();
    }
  }

  // iOS 平台播放器初始化
  Future<void> _initPlayerForIOS() async {
    try {
      final file = File(_recording!.filePath);
      if (!file.existsSync()) {
        print('_initPlayer: file does not exist: ${_recording!.filePath}');
        return;
      }

      print('_initPlayer iOS: ${_recording!.filePath}');

      // 使用 setFilePath 而不是 setUrl，更适合 iOS
      await _player.setFilePath(_recording!.filePath);

      // 等待播放器准备就绪
      await _player.load();

      print('iOS player initialized successfully');
    } catch (e) {
      print('_initPlayer iOS error: $e');
      // iOS 特定错误处理
      if (e.toString().contains('-11850')) {
        print('iOS audio session error detected, retrying...');
        await Future.delayed(Duration(milliseconds: 500));
        await _configureAudioSession();
        try {
          await _player.setFilePath(_recording!.filePath);
          await _player.load();
          print('iOS player retry successful');
        } catch (retryError) {
          print('iOS player retry failed: $retryError');
        }
      }
    }
  }

  // Android 平台播放器初始化
  Future<void> _initPlayerForAndroid() async {
    try {
      print('_initPlayer Android: ${_recording!.filePath}');
      await _player.setUrl(_recording!.filePath);
    } catch (e) {
      print('_initPlayer Android error: $e');
    }
  }

  void _setupStateListener() {

    if (Platform.isIOS) {
      AudioSession.instance.then((session) {
        session.interruptionEventStream.listen((event) {
          print('iOS Audio Session interruption: $event');
          if (event.begin) {
            switch (event.type) {
              case AudioInterruptionType.duck:
                print('iOS Audio Session ducked');
                break;
              case AudioInterruptionType.pause:
              case AudioInterruptionType.unknown:
                print('iOS Audio Session paused');
                if (_player.playing) {
                  _player.pause();
                }
                break;
            }
          } else {
            switch (event.type) {
              case AudioInterruptionType.duck:
                print('iOS Audio Session unducked');
                break;
              case AudioInterruptionType.pause:
              case AudioInterruptionType.unknown:
                print('iOS Audio Session resumed');
                break;
            }
          }
        });
      });
    }

    _player.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        await _player.pause();
        await _player.seek(Duration.zero, index: 0);
        setState(() {});
      }
    });

    // 添加播放进度监听
    _player.positionStream.listen((position) {
      if (transTextList.isNotEmpty && _isAutoScrollEnabled) {
        // 只在自动滚动启用时执行
        // 找到当前播放位置对应的文本索引
        int currentIndex = -1;
        for (int i = 0; i < transTextList.length; i++) {
          if (position.inMilliseconds >= transTextList[i].startTime &&
              position.inMilliseconds <= transTextList[i].endTime) {
            currentIndex = i;
            break;
          }
        }

        if (currentIndex != -1 && currentIndex != _hitIndexForCtx1) {
          setState(() {
            _hitIndexForCtx1 = currentIndex;
          });

          // 使用 ScrollController 直接控制滚动位置
          if (scrollController.hasClients) {
            // 计算目标滚动位置
            final screenHeight = MediaQuery.of(context).size.height;
            final viewportHeight = screenHeight * 0.6; // 可视区域高度
            final itemHeight = 100.0; // 每个文本项的大致高度

            // 计算当前项在列表中的位置
            final itemPosition = currentIndex * itemHeight;

            // 计算目标滚动位置，使当前项位于屏幕的 30% 位置
            final targetOffset = itemPosition - (viewportHeight * 0.3);

            // 确保滚动位置在有效范围内
            final maxScroll = scrollController.position.maxScrollExtent;
            final minScroll = scrollController.position.minScrollExtent;
            final clampedOffset = targetOffset.clamp(minScroll, maxScroll);

            // 计算当前滚动位置与目标位置的差值
            final currentOffset = scrollController.offset;
            final offsetDiff = (clampedOffset - currentOffset).abs();

            // 根据滚动距离调整动画时间，使用更平滑的曲线
            final duration = Duration(
                milliseconds: (offsetDiff * 0.5).clamp(300, 800).toInt());

            // 执行滚动，使用更平滑的动画曲线
            scrollController.animateTo(
              clampedOffset,
              duration: duration,
              curve: Curves.easeInOutCubic,
            );
          }
        }
      }
    });
  }

  // 播放暂停
  void _switchPlayStatue() async {
    try {
      if (_player.playing) {
        _player.pause();
      } else {
        if (Platform.isIOS) {
          // iOS 平台需要确保音频会话激活
          final session = await AudioSession.instance;
          await session.setActive(true);
        }
        await _player.play();
        _player.play();
      }
      setState(() {});
    } catch(e) {
      print('Play/Pause error: $e');
      if (Platform.isIOS && e.toString().contains('-11850')) {
        print('iOS audio session error, reconfiguring...');
        await _configureAudioSession();
        try {
          await _player.play();
          setState(() {});
        } catch (retryError) {
          print('iOS play retry failed: $retryError');
        }
      }
    }
  }

  // 跳转指定位置
  void _seekPosition(double seconds) async {
    try {
      await _player.seek(Duration(seconds: seconds.toInt()));
      if (!_player.playing) {
        _player.play();
      }
    } catch (e) {
      print('Error seeking audio: $e');
    }
    setState(() {});
  }

  // 跳转指定位置
  void _updatePostion(double seconds) async {
    try {
      double _duration = _player.position.inSeconds + seconds;
      if (_duration > _recording!.timeLong) {
        _duration = _recording!.timeLong.toDouble();
      } else if (_duration < 0) {
        _duration = 0;
      }
      _seekPosition(_duration);
    } catch (e) {
      print('Error seeking audio: $e');
    }
    setState(() {});
  }

  // 加速减速
  void _speed(double speed) async {
    try {
      await _player.setSpeed(speed);
      setState(() { // 更新状态以刷新UI
        _currentSpeed = speed;
      });
    } catch (e) {
      print('Error speed audio: $e');
    }
  }

  // 加载语言模型和总结模板
  Future<void> _loadModelsAndTemplates() async {
    if (_loadConfigLogic != null) {
      final engineResponse = await _loadConfigLogic!.getAsrEngineModels();
      final templateResponse = await _loadConfigLogic!.getPromptTemplates();

      setState(() {
        if (engineResponse.data != null) {
          engineModels = engineResponse.data!;
          if (engineModels.isNotEmpty) {
            selectedEngineType = engineModels[0].engineType;
          }
        }

        if (templateResponse.data != null) {
          promptTemplates = templateResponse.data!;
          if (promptTemplates.isNotEmpty) {
            selectedTemplateId = promptTemplates[0].promptId;
          }
        }
      });
    }
  }

  Future _startStatuTimer() async {
    // 第一次连接5秒扫描连上
    _statuTimer = Timer.periodic(_timePeriod, (timer) async {
      if (_recording!.isSummary != MediaStateEnum.SUMMARYED.state) {
        MediaResponse mediaResponse =
            await MediaCoreLogic(_recording!, '', '').getStatus();
        print('[DEBUG] _startStatuTimer: getStatus返回 code=${mediaResponse.code}, msg=${mediaResponse.msg}, isTranslatedLoading=$isTranslatedLoading');
        if (mediaResponse.code == ErrConstants.MEDIA_TRANSFERING_CODE ||
            mediaResponse.code == ErrConstants.MEDIA_SUMMARYING_CODE) {
          //转写中
          print('[DEBUG] _startStatuTimer: 转写/摘要进行中，显示loading');
          setState(() {
            isTranslatedLoading = true;
          });
        } else if (mediaResponse.code == ErrConstants.MEDIA_IS_SUMMARY_CODE) {
          //转写完成
          print('[DEBUG] _startStatuTimer: 转写+摘要完成，拉取结果');
          Recording? _recordingTmp =
              await recordingService.getResultById(_recording!.id!);
          setState(() {
            _recording = _recordingTmp;
            init();
            isTranslatedLoading = false;
          });
        } else {
          // 未上传/未转写等其他状态 —— 如果当前正在加载中，保持loading状态不取消
          print('[DEBUG] _startStatuTimer: 其他状态 code=${mediaResponse.code}, 当前isTranslatedLoading=$isTranslatedLoading');
          if (!isTranslatedLoading) {
            setState(() {
              isTranslatedLoading = false;
            });
          }
        }
      }
    });
  }

  /**
   * 1. 如果文件没有上传云端，执行上传云端，上传完执行转写和总结
   * 2. 如果没有转写内容，执行转写和总结
   * 3. 如果没有总结，执行总结
   */
  void _loadContent() async {
    print('[DEBUG] _loadContent: 开始上传, recording.id=${_recording?.id}, mediaId=${_recording?.mediaId}, selectedEngine=$selectedEngineType, selectedTemplate=$selectedTemplateId');
    unawaited(Future(() async {

      //, engineType: selectedEngineType, templateId: selectedTemplateId
      String result = await MediaCoreLogic(_recording!, selectedTemplateId, selectedEngineType).upload();
      print('[DEBUG] _loadContent: upload返回结果=$result');
    }));
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _recording = args?['recording'];
    mediaId = _recording?.mediaId ?? 0;
    if (_recording != null) {
      Recording? recording =
      await recordingService.getResultById(_recording!.id!);
      setState(() {
        if (recording != null) {
          _recording = recording;
        }
        if (_fileNameEditingController == null) {
          _fileNameEditingController =
              TextEditingController(text: _recording?.fileName);
        }
        init();

      });
      // 延迟初始化播放器，确保音频会话已配置
      if (Platform.isIOS) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      _initPlayer();
    }


  }

  void init() {
    isTranslated = _recording?.isTranslated ?? 0;
    transText = _recording?.transText ?? '';
    summaryText = _recording?.summaryText ?? '';
    if (transText.isNotEmpty) {
      transTextNoTime = "";
      //文本转List
      List<dynamic> textList = jsonDecode(transText);
      transTextList = textList.map((dynamic e) {
        if (e is Map<String, dynamic>) {
          Map<String, dynamic> map = e;
          transTextNoTime += map['text'] + '\n';
          return TransText.fromJson(map);
        }
        return TransText(
            index: 0, startTime: 0, endTime: 0, text: 'null', speakId: 0);
      }).toList();
    }
  }

  int _currentIndex = -1;

  @override
  void dispose() {
    observerController.controller?.dispose();
    if (_fileNameEditingController != null) {
      _fileNameEditingController!.dispose();
    }
    if (_statuTimer != null) {
      _statuTimer!.cancel();
    }
    if (_player != null) {
      _player.dispose();
    }
    super.dispose();
  }

  String _menu = "summary";

  Future<void> _handleTranscription(String action) async {
    if (_isTransLoading) return;
    setState(() {
      _isTransLoading = true;
    });
    try {
      if (await packageLogic.isHasTrans()) {
        if (action == 'tansText') {
          _loadContent();
        }
        if (action == 'askAI') {
          _showAskAI();
        }
        if (action == 'summaryPage') {
          if (_recording != null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SummaryPage(
                    recording: _recording!, promptId: selectedTemplateId)));
          }
        }
        if (action == 'askAiPage') {
          if (_recording != null) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AskAiPage(recording: _recording!)));
          }
        }
        if (action == 'exportSheet') {
          _showExportSheet();
        }
      } else {
        BuyRecommendWidget.showDialog(context);
      }
    } finally {
      setState(() {
        _isTransLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.black, size: 22),
            onPressed: () => _showEditFileName(),
          ),
          IconButton(
            icon: Icon(Icons.compare_arrows, color: Colors.black, size: 22),
            onPressed: () => _showSTT(),
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.black, size: 22),
            onPressed: () => _showShareSheet(),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black, size: 22),
            onPressed: () => _showExportSheet(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.8),
                          Colors.purple.withOpacity(0.8)
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SliverViewObserver(
                          controller: observerController,
                          child: _buildScrollView(),
                          sliverContexts: () {
                            return [
                              if (_sliverListCtx != null) _sliverListCtx!,
                            ];
                          }),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: InkWell( // 将 Text 包裹在 InkWell 中以响应点击
                      onTap: _showSpeedMenu, // 点击时显示菜单
                      child: Container( // 添加一个容器便于对齐和填充
                        alignment: Alignment.centerLeft, // 左对齐
                        padding: EdgeInsets.symmetric(vertical: 8.0), // 添加一些垂直内边距
                        child: Text(
                          '${_currentSpeed}x', // 显示当前速度
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500, // 加粗一点
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.replay_5,
                              color: Colors.black, size: 28),
                          onPressed: () {
                            // TODO: 实现快退5秒
                            _updatePostion(-5);
                          },
                        ),
                        Container(
                          width: 56,
                          height: 56,
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: IconButton(
                            icon: _player.playing
                                ? Icon(Icons.pause,
                                    color: Colors.white, size: 32)
                                : Icon(Icons.play_arrow,
                                    color: Colors.white, size: 32),
                            onPressed: () {
                              _switchPlayStatue();
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.forward_5,
                              color: Colors.black, size: 28),
                          onPressed: () {
                            // TODO: 实现快进5秒
                            _updatePostion(5);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StreamBuilder<Duration>(
                          stream: _player.positionStream,
                          builder: (context, snapshot) {
                            return Text(DateUtil.formatPlayerDuration(
                                snapshot.data ?? Duration.zero));
                          },
                        ),
                        StreamBuilder<Duration?>(
                          stream: _player.durationStream,
                          builder: (context, snapshot) {
                            return Text(DateUtil.formatPlayerDuration(
                                snapshot.data ?? Duration.zero));
                          },
                        ),
                        /*Text(
                          '00:00',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),*/
                        /*Text(
                          '00:20',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 显示速度选择菜单
   */
  void _showSpeedMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // 背景设为白色
      shape: RoundedRectangleBorder( // 添加圆角
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints( // 限制最大高度
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: ListView.builder(
            shrinkWrap: true, // 自适应内容高度
            itemCount: _availableSpeeds.length,
            itemBuilder: (context, index) {
              final speed = _availableSpeeds[index];
              final bool isSelected = speed == _currentSpeed;
              return ListTile(
                title: Text(
                  '${speed}x',
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black, // 选中项蓝色
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null, // 选中项显示勾号
                onTap: () {
                  _speed(speed); // 调用更新速度的方法
                  Navigator.pop(context); // 关闭菜单
                },
              );
            },
          ),
        );
      },
    );
  }

  /**
   * 文件名上方 AI 菜单：AI总结 / 问一问
   * 样式参考 ListPage 的"连接硬件 / 开始录音"
   */
  Widget _buildAiMenuRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAiMenuButton(
          label: S.of(context).PlayerPage_k39, // AI总结
          bgColor: Color(0xFF6C63FF),
          onTap: () => _handleTranscription('summaryPage'),
        ),
        SizedBox(width: 8),
        _buildAiMenuButton(
          label: S.of(context).PlayerPage_k40, // 问一问
          bgColor: Color(0xFF2196F3),
          onTap: () => _handleTranscription('askAiPage'),
        ),
      ],
    );
  }

  Widget _buildAiMenuButton({
    required String label,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * 构建滚动视图
   */
  Widget _buildScrollView() {
    return CustomScrollView(
      controller: scrollController,
      physics: ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 16),
                _buildAiMenuRow(),
                SizedBox(height: 16),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _recording!.fileName,
                    style: TextStyle(
                      fontFamily: 'Inter-Medium',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 5),
                          Text(
                            DateUtil.formatMillisecond(
                                _recording!.createdAt, DateUtil.YMD_HMS_STD),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 5),
                          Text(
                            DateUtil.formatSeconds(_recording!.timeLong),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Divider(
                  color: Color(0xFFABADC0),
                  thickness: 0.5,
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
        isTranslatedLoading
            ? SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SpinKitThreeBounce(
                        color: Colors.black,
                        size: 25,
                      ),
                      Text(
                        S.of(context).PlayerPage_k3,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFABADC0),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : TransTextWidget(
                transText: transText,
                hitIndexForCtx1: _hitIndexForCtx1,
                onHit: (context) {
                  _sliverListCtx ??= context;
                },
                recording: _recording!,
                textPressed: (duration, index) {
                  print('onTap2:' + duration.toString());
                  _hitIndexForCtx1 = index;
                  _seekPosition((duration ~/ 1000).toDouble());
                },
                onScrollStart: () {
                  setState(() {
                    _isAutoScrollEnabled = false;
                  });
                },
                onScrollEnd: () {
                  setState(() {
                    _isAutoScrollEnabled = true;
                  });
                },
              ),
      ],
    );
  }

  /**
   * 保存文件名
   */
  void _saveFileName() {
    String fileName = _fileNameEditingController!.text.trim();
    if (fileName.isEmpty) {
      showAlertDialog(S.of(context).PlayerPage_k13);
      return;
    }

    recordingService.updateFileName(_recording!.id!, fileName);
    setState(() {
      _recording!.fileName = fileName;
    });
    Navigator.pop(context);
    showAlertDialog(S.of(context).PlayerPage_k14);
  }

  /**
   * 显示提示框
   */
  void showAlertDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  msg,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // 提示框显示1.5秒后关闭
    Future.delayed(Duration(milliseconds: 1500), () {
      Navigator.of(context).pop();
    });
  }

  /**
   * 编辑文件名称
   */
  void _showEditFileName() {
    showModalBottomSheet(
      context: context,
      elevation: 1,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).PlayerPage_k9,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                Container(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _fileNameEditingController,
                    cursorColor: Colors.blue,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 1,
                        ),
                      ),
                      hintText: S.of(context).PlayerPage_k10,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              S.of(context).PlayerPage_k11,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _saveFileName,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.blue.shade700],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              S.of(context).PlayerPage_k12,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  OverlayEntry? _overlayEntry;

  void _addMask() {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned.fill(
        bottom: 0,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                S.of(context).PlayerPage_k33,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _removeMask() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
    }
    setState(() {
      _overlayEntry = null;
    });
  }

  String languageSelectedValue = CommonConstants.language[0];
  String summarySelectedValue = CommonConstants.summaryTemplate[0];
  String dialogSelectedValue = CommonConstants.selectDialog[0];

  /**
   * 语音识别与转写的参数选择框
   */
  void _showSTT() {
    showModalBottomSheet(
        context: context,
        elevation: 1,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F4F8),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).PlayerPage_k34,
                              style: TextStyle(
                                fontSize: 18,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.highlight_off,
                                  color: Colors.black45,
                                )),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width - 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.of(context).PlayerPage_k35, style: TextStyle(fontSize: 14)),
                            SizedBox(height: 10),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 2.5,
                              ),
                              itemCount: engineModels.length > 6
                                  ? 6
                                  : engineModels.length,
                              itemBuilder: (context, index) {
                                if (engineModels.length > 6 && index == 5) {
                                  final isSelected = !engineModels.take(5).any(
                                      (model) =>
                                          model.engineType ==
                                          selectedEngineType);
                                  // 显示"更多"选项
                                  //final isSelected = engineModels.any((model) => model.engineType == selectedEngineType);

                                  return InkWell(
                                    onTap: () {
                                      _showMoreLanguages(context, setState);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey[300]!,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            isSelected
                                                ? engineModels
                                                            .firstWhere((model) =>
                                                                model
                                                                    .engineType ==
                                                                selectedEngineType)
                                                            .engineDesc
                                                            .length >
                                                        5
                                                    ? engineModels
                                                            .firstWhere((model) =>
                                                                model
                                                                    .engineType ==
                                                                selectedEngineType)
                                                            .engineDesc
                                                            .substring(0, 5) +
                                                        '...'
                                                    : engineModels
                                                        .firstWhere((model) =>
                                                            model.engineType ==
                                                            selectedEngineType)
                                                        .engineDesc
                                                : S.of(context).PlayerPage_k48,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          //if (!isSelected)
                                          Icon(
                                            Icons.keyboard_arrow_right,
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey[300]!,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final model = engineModels[index];
                                final isSelected =
                                    selectedEngineType == model.engineType;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedEngineType = model.engineType;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            model.engineDesc.length > 5
                                                ? model.engineDesc
                                                        .substring(0, 5) +
                                                    '...'
                                                : model.engineDesc,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        /*if (isSelected)
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  bottomRight:
                                                      Radius.circular(8),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),*/
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width - 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.of(context).PlayerPage_k36, style: TextStyle(fontSize: 14)),
                            SizedBox(height: 10),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 2.5,
                              ),
                              itemCount: promptTemplates.length > 6
                                  ? 6
                                  : promptTemplates.length,
                              itemBuilder: (context, index) {
                                if (promptTemplates.length > 6 && index == 5) {
                                  final isSelected = !promptTemplates.take(5).any(
                                      (template) =>
                                          template.promptId ==
                                          selectedTemplateId);
                                  // 显示"更多"选项
                                  return InkWell(
                                    onTap: () {
                                      _showMoreTemplates(context, setState);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey[300]!,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            isSelected
                                                ? promptTemplates
                                                            .firstWhere((template) =>
                                                                template.promptId ==
                                                                selectedTemplateId)
                                                            .promptDesc
                                                            .length >
                                                        5
                                                    ? promptTemplates
                                                            .firstWhere((template) =>
                                                                template.promptId ==
                                                                selectedTemplateId)
                                                            .promptDesc
                                                            .substring(0, 5) +
                                                        '...'
                                                    : promptTemplates
                                                        .firstWhere((template) =>
                                                            template.promptId ==
                                                            selectedTemplateId)
                                                        .promptDesc
                                                : S.of(context).PlayerPage_k48,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_right,
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey[300]!,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final template = promptTemplates[index];
                                final isSelected =
                                    selectedTemplateId == template.promptId;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedTemplateId = template.promptId;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            template.promptDesc.length > 5
                                                ? template.promptDesc
                                                        .substring(0, 5) +
                                                    '...'
                                                : template.promptDesc,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      InkWell(
                        onTap: () async {
                          if (!isTranslatedLoading) {
                            if (await packageLogic.isHasTrans()) {
                              Navigator.pop(context);
                              setState(() {
                                isTranslatedLoading = true;
                              });
                              _loadContent();
                              showAlertDialog(S.of(context).PlayerPage_k8);
                            } else {
                              Navigator.pop(context);
                              BuyRecommendWidget.showDialog(context);
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width - 40,
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            S.of(context).PlayerPage_k7,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  final ChatGPTService _chatGPTService = ChatGPTService();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [
    /*{
      "role": "assistant",
      "content": "Hi,我是您的AI助手！有什么可以帮到您呢？可以参考下面来问我～  \n"
          "1. 帮我总结一下会议的核心要点  \n"
          "2. 请整理一下会议的待办事项  \n"
          ""
    }*/
  ]; // 存储聊天记录

  // 发送消息
  void _sendMessage(
      BuildContext context, StateSetter setState, String message) async {
    var userMessage = '';
    if (message == null || message.isEmpty) {
      userMessage = _controller.text.trim();
    } else {
      userMessage = message;
    }
    if (userMessage.isEmpty) return;
    var content = userMessage;

    if (dialogSelectedValue == CommonConstants.selectDialog[0]) {
      if (transTextNoTime.isNotEmpty) {
        userMessage = transTextNoTime + '\n' + userMessage;
      }
    }

    // 添加用户消息到聊天记录
    setState(() {
      _messages.add({"role": "user", "content": content});
      _scrollToBottom();
    });
    _controller.clear();

    if (dialogSelectedValue == CommonConstants.selectDialog[0] &&
        transTextNoTime.isEmpty) {
      setState(() {
        _messages.add({"role": "assistant", "content": S.of(context).PlayerPage_k37});
        _scrollToBottom();
      });
    } else {
      // 显示一个临时的加载状态
      setState(() {
        _messages.add({"role": "assistant", "content": S.of(context).PlayerPage_k38});
        _scrollToBottom();
      });

      // 调用 ChatGPT 接口获取回复
      final gptResponse = await _chatGPTService.sendMessageOK(userMessage);

      // 移除临时加载状态，并更新 GPT 响应
      setState(() {
        _messages.removeLast(); // 移除 "正在生成回复..."
        _messages.add({"role": "assistant", "content": gptResponse});
        _scrollToBottom();
      });
    }
  }

  // 在需要滚动到底部的地方调用(比如添加新消息后)
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  //askAI操作
  void _showAskAI() {
    showModalBottomSheet(
        context: context,
        elevation: 1,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // 处理键盘高度
              ),
              child: SafeArea(
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ), // 设置圆角半径
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 180,
                                height: 35,
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                alignment: Alignment.center,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      color: Colors.grey[900]!, width: 0.5),
                                  color: Colors.grey[900],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: _menu == 'summary'
                                          ? InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _menu = 'summary';
                                                });
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                height: 30,
                                                width: 80,
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.blue,
                                                      Colors.purple
                                                    ],
                                                    begin:
                                                        Alignment.bottomRight,
                                                    end: Alignment.topLeft,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.purple, // 阴影颜色
                                                      blurRadius: 5.0, // 阴影模糊半径
                                                      offset:
                                                          Offset(2, 2), // 阴影偏移量
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                child: Text(
                                                  S.of(context).PlayerPage_k39,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _menu = 'summary';
                                                });
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: 80,
                                                padding: EdgeInsets.all(2),
                                                child: Text(
                                                  S.of(context).PlayerPage_k39,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                    ),
                                    Expanded(
                                      //flex: 1,
                                      child: _menu == 'askai'
                                          ? InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _menu = 'askai';
                                                });
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatScreen()));
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                height: 30,
                                                width: 80,
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.blue,
                                                      Colors.purple
                                                    ],
                                                    begin:
                                                        Alignment.bottomRight,
                                                    end: Alignment.topLeft,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.purple, // 阴影颜色
                                                      blurRadius: 3.0, // 阴影模糊半径
                                                      offset:
                                                          Offset(2, 2), // 阴影偏移量
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                child: Text(
                                                  S.of(context).PlayerPage_k40,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _menu = 'askai';
                                                });
                                              },
                                              child: Container(
                                                width: 80,
                                                padding: EdgeInsets.all(2),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  S.of(context).PlayerPage_k40,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 25,
                                weight: 5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _menu == 'askai'
                          ? Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _messages.length + 5,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        S.of(context).PlayerPage_k22,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    );
                                  }
                                  if (index < 5) {
                                    return Container(
                                      alignment: Alignment.center,
                                      child: Column(children: [
                                        InkWell(
                                          onTap: () {
                                            _sendMessage(
                                                context,
                                                setState,
                                                CommonConstants
                                                    .promptList[index - 1]);
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[800],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.all(5),
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      CommonConstants
                                                              .promptIconList[
                                                          index - 1],
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      CommonConstants
                                                              .promptList[
                                                          index - 1],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                Icon(
                                                  Icons.keyboard_arrow_right,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ]),
                                    );
                                  }
                                  final message = _messages[index - 5];
                                  final isUser = message['role'] == 'user';
                                  return Container(
                                    alignment: isUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isUser
                                            ? Colors.blue[800]
                                            : Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: MathMarkdown(
                                        data: message['content'] ?? '',
                                        selectable: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Expanded(
                              child: CustomScrollView(
                                slivers: [
                                  SliverList(
                                    delegate: SliverChildListDelegate(
                                      [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.all(10),
                                          child: MathMarkdown(
                                            data: _recording!.transText.isEmpty
                                                ? S.of(context).PlayerPage_k24
                                                : _recording!.summaryText ==
                                                            '' ||
                                                        _recording!
                                                                .summaryText ==
                                                            null
                                                    ? S.of(context).PlayerPage_k23
                                                    : _recording!.summaryText,
                                            selectable: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      _menu == 'askai'
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: 100, // 设置最大高度
                                          ),
                                          child: TextField(
                                            maxLines: null,
                                            minLines: 1,
                                            keyboardType:
                                                TextInputType.multiline,
                                            textInputAction:
                                                TextInputAction.newline,
                                            controller: _controller,
                                            style: TextStyle(
                                                color: Colors.white,
                                                height: 1.5,
                                                fontSize: 14),
                                            decoration: InputDecoration(
                                              hintText: S.of(context).PlayerPage_k41,
                                              hintStyle: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  fontSize: 14),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                              filled: true,
                                              fillColor:
                                                  Colors.white.withOpacity(0.1),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                borderSide: BorderSide(
                                                  //Colors.blue,
                                                  color: Colors.blue
                                                      .withOpacity(0.5),
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6, // 缩小为原来的2/3
                                        child: Row(
                                          children: CommonConstants.selectDialog
                                              .map((String value) {
                                            bool isSelected =
                                                dialogSelectedValue == value;
                                            return Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    dialogSelectedValue = value;
                                                  });
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 4),
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    gradient: isSelected
                                                        ? LinearGradient(
                                                            colors: [
                                                                Colors.blue
                                                                    .withOpacity(
                                                                        0.3),
                                                                Colors.purple
                                                                    .withOpacity(
                                                                        0.3)
                                                              ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight)
                                                        : null,
                                                    color: isSelected
                                                        ? null
                                                        : Colors.grey
                                                            .withOpacity(0.5),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Colors.blue
                                                              .withOpacity(0.3)
                                                          : Colors.transparent,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          value,
                                                          style: TextStyle(
                                                            color: isSelected
                                                                ? Colors.blue
                                                                : Colors.white
                                                                    .withOpacity(
                                                                        0.7),
                                                            fontSize: 13,
                                                            fontWeight:
                                                                isSelected
                                                                    ? FontWeight
                                                                        .w500
                                                                    : FontWeight
                                                                        .normal,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue,
                                                Colors.purple
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ]),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              _sendMessage(
                                                  context, setState, '');
                                            },
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                            )
                          : SizedBox(
                              height: 0,
                            ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  /**
   * 复制到剪贴板
   * @param text 复制的文本
   */
  void copyToClipboard(String text) {
    FlutterClipboard.copy(text).then((_) {
      showAlertDialog(S.of(context).PlayerPage_k42);
    });
  }

  /**
   * 二级菜单，更多功能往这里添加
   * 点击更多弹出底部菜单窗口
   */
  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      elevation: 1,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3, // 调整高度为原来的30%
          ),
          decoration: BoxDecoration(
            color: Color(0xFFF3F4F8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).PlayerPage_k4,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          S.of(context).PlayerPage_k43,
                          'assets/images/copy1.png',
                          () {
                            copyToClipboard(transTextNoTime);
                            Navigator.pop(context);
                          },
                        ),
                        _buildMenuItem(
                          S.of(context).PlayerPage_k45,
                          'assets/images/copy2.png',
                          () {
                            copyToClipboard(_recording!.summaryText);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(String title, String iconPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(width: 16),
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String exportType = 'TXT';
  bool _isSwitched = true; // 用于保存开关的状态

  /**
   * 导出弹窗
   */
  void _showExportName(String content, String type) {
    showModalBottomSheet(
        context: context,
        elevation: 1,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              alignment: Alignment.center,
              height: type == 'trans' ? 500 : 300,
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F8),
                borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
              ),
              padding:
                  EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).PlayerPage_k19,
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.highlight_off,
                            color: Colors.black,
                            size: 20,
                          )),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[300]!,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
                    ),
                    child: Column(
                      children: [
                        InkWell(
                            onTap: () {
                              setState(() {
                                exportType = 'TXT';
                              });
                            },
                            child: Container(
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/file-text.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          SizedBox(width: 20),
                                          Text('TXT',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400)),
                                        ]),
                                    exportType == 'TXT'
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.black,
                                          )
                                        : Container(),
                                  ]),
                            )),
                        Divider(
                          height: 0,
                          color: Colors.grey[200],
                          indent: 20,
                          endIndent: 20,
                        ),
                        type == 'trans'
                            ? Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      exportType = 'SRT';
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/file-music.png',
                                              width: 24,
                                              height: 24,
                                            ),
                                            SizedBox(width: 20),
                                            Text('SRT',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          ]),
                                      exportType == 'SRT'
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.black,
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        Divider(
                          height: 0,
                          color: Colors.grey[200],
                          indent: 20,
                          endIndent: 20,
                        ),
                        InkWell(
                            onTap: () {
                              setState(() {
                                exportType = 'DOCX';
                              });
                            },
                            child: Container(
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/file-word.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                        SizedBox(width: 20),
                                        Text('DOCX',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400)),
                                      ]),
                                  exportType == 'DOCX'
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.black,
                                        )
                                      : Container(),
                                ],
                              ),
                            )),
                        Divider(
                          height: 0,
                          color: Colors.grey[200],
                          indent: 20,
                          endIndent: 20,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              exportType = 'PDF';
                            });
                          },
                          child: Container(
                            height: 40,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/file-pdf.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      'PDF',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                exportType == 'PDF'
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.black,
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  type == 'trans'
                      ? Container(
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width - 40,
                          child: Text(
                            S.of(context).PlayerPage_k47,
                            style: TextStyle(fontSize: 15),
                          ),
                        )
                      : SizedBox(),
                  SizedBox(height: 10),
                  type == 'trans'
                      ? Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width - 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    exportType = 'TXT';
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(S.of(context).PlayerPage_k21,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          ],
                                        ),
                                        Switch(
                                          value: _isSwitched,
                                          // 当前状态
                                          onChanged: (value) {
                                            setState(() {
                                              _isSwitched = value; // 更新状态
                                            });
                                          },
                                          activeColor: Colors.white,
                                          // 开启时滑块的颜色
                                          inactiveThumbColor: Colors.grey,
                                          // 关闭时滑块的颜色
                                          activeTrackColor: Colors.blue,
                                          // 开启时轨道的颜色
                                          inactiveTrackColor:
                                              Colors.transparent, // 关闭时轨道的颜色
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      if (exportType == 'TXT') {
                        exportTxtFile(type);
                      } else if (exportType == 'DOCX') {
                        exportToDocx(type);
                      } else if (exportType == 'PDF') {
                        exportPdfFile(type);
                      } else if (exportType == 'SRT') {
                        exportSRTFile(type);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 40,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26, // 阴影颜色
                            blurRadius: 5.0, // 阴影模糊半径
                            offset: Offset(2, 2), // 阴影偏移量
                          ),
                        ],
                      ),
                      //child: Container(),
                      child: Text(
                        S.of(context).PlayerPage_k20,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Future<void> exportToDocx(String type) async {
    final data = await rootBundle.load('assets/template2.docx');
    final bytes = data.buffer.asUint8List();
    final docx = await DocxTemplate.fromBytes(bytes);

    String fileContent = '';
    if (type == 'trans') {
      //导出转写文本
      List<dynamic> textList = jsonDecode(_recording!.transText);
      int startTime = 0;
      for (int i = 0; i < textList.length; i++) {
        if (i == 0) {
          startTime = textList[i]['start_time'];
        }
        if (_isSwitched) {
          int displayTime = textList[i]['start_time'] - startTime;
          String displayTimeStr = formatMilliseconds(displayTime);
          fileContent += displayTimeStr + '\n' + textList[i]['text'] + '\n\n';
        } else {
          fileContent += textList[i]['text'] + '\n\n';
        }
      }
    } else {
      //导出总结
      fileContent = _recording!.summaryText;
    }
    // 定义文件名和内容
    String fileName = _recording!.fileName + '_' + type + '.docx';

    Directory appDocDir = await getTemporaryDirectory();
    String appDocPath = appDocDir.path;

    // 创建文件路径
    String filePath = '$appDocPath/$fileName';

    Content content = Content();
    content.add(TextContent("content", 'oinsdnfsdi'));
    final docGenerated = await docx.generate(content);

    final fileGenerated = File(filePath);
    if (docGenerated != null) await fileGenerated.writeAsBytes(docGenerated);
    // 分享生成的 DOCX 文件
    Share.shareXFiles([XFile(filePath)],
        text: 'Check out this DOCX file!', subject: fileName);
  }

  /**
   * 导出文本文件
   * @param type 类型
   */
  Future<void> exportTxtFile(String type) async {
    // 获取应用程序的文档目录
    Directory appDocDir = await getTemporaryDirectory();
    String appDocPath = appDocDir.path;
    String fileContent = '';
    if (type == 'trans') {
      //导出转写文本
      List<dynamic> textList = jsonDecode(_recording!.transText);
      int startTime = 0;
      for (int i = 0; i < textList.length; i++) {
        if (i == 0) {
          startTime = textList[i]['start_time'];
        }
        if (_isSwitched) {
          int displayTime = textList[i]['start_time'] - startTime;
          String displayTimeStr = formatMilliseconds(displayTime);
          fileContent += displayTimeStr + '\n' + textList[i]['text'] + '\n\n';
        } else {
          fileContent += textList[i]['text'] + '\n\n';
        }
      }
    } else {
      //导出总结
      fileContent = _recording!.summaryText;
    }
    // 定义文件名和内容
    String fileName = _recording!.fileName + '_' + type + '.txt';

    // 创建文件路径
    String filePath = '$appDocPath/$fileName';

    // 创建文件并写入内容
    File file = File(filePath);
    await file.writeAsString(fileContent);
    await Share.shareXFiles([XFile(filePath)],
        text: fileName, subject: fileName);
  }

  //导出srt文件
  Future<void> exportSRTFile(String type) async {
    // 获取应用程序的文档目录
    Directory appDocDir = await getTemporaryDirectory();
    String appDocPath = appDocDir.path;
    String fileContent = '';
    final buffer = StringBuffer();
    if (type == 'trans') {
      //导出转写文本
      List<dynamic> textList = jsonDecode(_recording!.transText);
      int startTime = 0;
      for (int i = 0; i < textList.length; i++) {
        buffer.writeln('${i + 1}');
        int startTime = textList[i]['start_time'];
        int endTime = textList[i]['end_time'];
        String startTimeStr = formatMilliseconds(startTime) + ',000';
        String endTimeStr = formatMilliseconds(endTime) + ',000';
        buffer.writeln(startTimeStr + ' --> ' + endTimeStr);
        buffer.writeln(textList[i]['text']);
      }
      fileContent = buffer.toString();
    } else {
      return;
    }
    // 定义文件名和内容
    String fileName = _recording!.fileName + '_' + type + '.srt';

    // 创建文件路径
    String filePath = '$appDocPath/$fileName';

    // 创建文件并写入内容
    File file = File(filePath);
    await file.writeAsString(fileContent);
    await Share.shareXFiles([XFile(filePath)],
        text: fileName, subject: fileName);
  }

  /**
   * 导出PDF文件
   * @param type 类型
   */
  Future<void> exportPdfFile(String type) async {
    // 获取应用程序的文档目录
    Directory appDocDir = await getTemporaryDirectory();
    String appDocPath = appDocDir.path;
    String fileContent = '';
    if (type == 'trans') {
      //导出转写文本
      List<dynamic> textList = jsonDecode(_recording!.transText);
      int startTime = 0;
      for (int i = 0; i < textList.length; i++) {
        if (i == 0) {
          startTime = textList[i]['start_time'];
        }
        if (_isSwitched) {
          int displayTime = textList[i]['start_time'] - startTime;
          String displayTimeStr = formatMilliseconds(displayTime);
          fileContent += displayTimeStr + '\n' + textList[i]['text'] + '\n\n';
        } else {
          fileContent += textList[i]['text'] + '\n\n';
        }
      }
    } else {
      //导出总结
      fileContent = _recording!.summaryText;
    }
    // 定义文件名和内容
    String fileName = _recording!.fileName + '_' + type + '.pdf';

    // 创建文件路径
    String filePath = '$appDocPath/$fileName';

    final regularFontData =
        await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final boldFontData =
        await rootBundle.load("assets/fonts/NotoSans-Bold.ttf");
    final cjkscFontData =
        await rootBundle.load("assets/fonts/NotoSansSC-Regular.ttf");
    final cjkjpFontData =
        await rootBundle.load("assets/fonts/NotoSansJP-Regular.ttf");
    final cjkkrFontData =
        await rootBundle.load("assets/fonts/NotoSansSC-Regular.ttf");

    final regularFont = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);
    final cjkscFont = pw.Font.ttf(cjkscFontData);
    final cjkjpFont = pw.Font.ttf(cjkjpFontData);
    final cjkkrFont = pw.Font.ttf(cjkkrFontData);
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
        fontFallback: [
          cjkscFont,
          cjkjpFont,
          cjkkrFont,
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        // 设置页面格式
        pageFormat: PdfPageFormat.a4,
        // 设置页边距
        margin: pw.EdgeInsets.all(32),
        // 构建页眉
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.Header(
              level: 0,
              child: pw.Text(
                _recording!.fileName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
          }
          return pw.Container();
        },
        // 构建页脚
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              S.of(this.context).PlayerPage_k49(context.pageNumber.toString(), context.pagesCount.toString()),
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          );
        },
        // 构建正文内容
        build: (pw.Context context) {
          return [
            pw.Paragraph(
              text: fileContent,
              style: pw.TextStyle(
                fontSize: 12,
                lineSpacing: 1.5,
              ),
            ),
          ];
        },
      ),
    );

    // 创建文件并写入内容
    File file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(filePath)],
        text: fileName, subject: fileName);
  }

  String formatMilliseconds(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showMoreLanguages(BuildContext context, StateSetter parentSetState) {
    showModalBottomSheet(
      context: context,
      elevation: 1,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 400,
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(this.context).PlayerPage_k5,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: engineModels.length,
                      itemBuilder: (context, index) {
                        var model = engineModels[index];
                        //final language = CommonConstants.language[index];
                        return InkWell(
                          onTap: () {
                            parentSetState(() {
                              selectedEngineType = model.engineType;
                              //languageSelectedValue = language;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedEngineType == model.engineType
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  model.engineDesc,
                                  style: TextStyle(
                                    color:
                                        selectedEngineType == model.engineType
                                            ? Colors.blue
                                            : Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                if (selectedEngineType == model.engineType)
                                  Icon(
                                    Icons.check,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMoreTemplates(BuildContext context, StateSetter parentSetState) {
    showModalBottomSheet(
      context: context,
      elevation: 1,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 400,
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(this.context).PlayerPage_k6,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: promptTemplates.length,
                      itemBuilder: (context, index) {
                        final template = promptTemplates[index];
                        return InkWell(
                          onTap: () {
                            parentSetState(() {
                              selectedTemplateId = template.promptId;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedTemplateId == template.promptId
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    template.promptDesc,
                                    style: TextStyle(
                                      color: selectedTemplateId ==
                                              template.promptId
                                          ? Colors.blue
                                          : Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (selectedTemplateId == template.promptId)
                                  Icon(
                                    Icons.check,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      elevation: 1,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFF3F4F8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(this.context).PlayerPage_k15,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _buildShareMenuItem(
                          S.of(this.context).PlayerPage_k16,
                          'assets/images/export_media.png',
                          () async {
                            Navigator.pop(context);
                            await Share.shareXFiles(
                              [XFile(_recording!.filePath)],
                              text: _recording!.fileName,
                              subject: _recording!.fileName,
                            );
                          },
                        ),
                        _buildShareMenuItem(
                          S.of(this.context).PlayerPage_k17,
                          'assets/images/export_trans.png',
                          () {
                            Navigator.pop(context);
                            _showExportName(_recording!.transText, 'trans');
                          },
                        ),
                        _buildShareMenuItem(
                          S.of(this.context).PlayerPage_k18,
                          'assets/images/export_summary.png',
                          () {
                            Navigator.pop(context);
                            _showExportName(_recording!.summaryText, 'summary');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareMenuItem(
      String title, String iconPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(width: 16),
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  MySliverPersistentHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(MySliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
