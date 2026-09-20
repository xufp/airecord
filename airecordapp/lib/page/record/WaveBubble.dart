import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaveBubble extends StatefulWidget {
  final bool isSender;
  final int? index;
  final String? filePath;
  final double? width;
  final Function(int) onValueChanged;

  //final Directory appDirectory;

  const WaveBubble({
    Key? key,
    //required this.appDirectory,
    this.width,
    this.index,
    this.isSender = false,
    this.filePath,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  WaveBubbleState createState() => WaveBubbleState();
}

class WaveBubbleState extends State<WaveBubble> {
  File? file;

  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  late StreamSubscription<int> playerDurationSubscription;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.grey,
    liveWaveColor: Colors.red,
    spacing: 1,
    waveThickness: 0.5,
    seekLineColor: Colors.red,
    seekLineThickness: 1.0,
    showSeekLine: false,
    scaleFactor: 100,
    waveCap: StrokeCap.square,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    _preparePlayer();
    playerStateSubscription = controller.onPlayerStateChanged.listen((_) {
      setState(() {});
    });
    controller.onCompletion.listen((e) async {
      controller.seekTo(0);
      await controller.pausePlayer();
    });
    playerDurationSubscription =
        controller.onCurrentDurationChanged.listen((duration) {
      widget.onValueChanged(duration);
    });
  }

  void _preparePlayer() async {
    // Opening file from assets folder
    if (widget.index != null) {
      file = File(widget.filePath!);
      await file?.readAsBytes();
      /* (await rootBundle.load('assets/audios/audio${widget.index}.mp3'))
              .buffer
              .asUint8List());*/
    }
    if (widget.index == null && widget.filePath == null && file?.path == null) {
      return;
    }
    // Prepare player with extracting waveform if index is even.
    controller.preparePlayer(
      path: widget.filePath ?? file!.path,
      shouldExtractWaveform: widget.index?.isEven ?? true,
    );
    // Extracting waveform separately if index is odd.
    //if (widget.index?.isOdd ?? false) {
    controller
        .extractWaveformData(
          path: widget.filePath ?? file!.path,
          noOfSamples: playerWaveStyle.getSamplesForWidth(widget.width ?? 200),
        )
        .then((waveformData) => debugPrint(waveformData.toString()));
    //}
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    playerDurationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.filePath != null || file?.path != null
        ? Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 210,
              height: 30,
              padding: EdgeInsets.only(left: 10, right: 0, top: 0, bottom: 0),
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              //12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white, width: 0.5),
                color: Color(0xFFF3F4F8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //if (!controller.playerState.isStopped)
                  InkWell(
                    onTap: () async {
                      controller.playerState.isPlaying
                          ? await controller.pausePlayer()
                          : await controller.startPlayer(
                              finishMode: FinishMode.pause,
                            );
                    },
                    child: Container(
                      width: 25,
                      height: 25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      child: controller.playerState.isPlaying
                          ? Icon(Icons.pause, size: 15)
                          : Icon(Icons.play_arrow_rounded, size: 15),
                    ),
                  ),
                  //SizedBox(width: 20),
                  AudioFileWaveforms(
                    size: Size(150, 15),
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    playerController: controller,
                    waveformType: WaveformType.fitWidth,
                    //: WaveformType.long,
                    playerWaveStyle: playerWaveStyle,
                    animationCurve: Curves.linear,
                    enableSeekGesture: true,
                  ),
                  //if (widget.isSender) const SizedBox(width: 10),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
