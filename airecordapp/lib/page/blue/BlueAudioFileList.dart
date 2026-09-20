import 'package:airecordapp/controller/BlueController.dart';
import 'package:airecordapp/enum/ImportStateEnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class BlueAudioFileList extends StatefulWidget {
  @override
  _BlueAudioFileListState createState() => _BlueAudioFileListState();
}

class _BlueAudioFileListState extends State<BlueAudioFileList> {
  final BlueController blueController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getWavFileName(String fileOrgName) {
    // 获取输入音频文件名
    List<String> parts = fileOrgName.split('.');
    String fileName = parts.first + '.wav';
    return fileName;
  }

  Widget _buildSyncStatus(double progress) {
    if (progress >= 1.0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              S.of(context).BlueAudioFileList_k2,
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          S.of(context).BlueAudioFileList_k1,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 重新开始同步音频
          blueController.autoImportFile();
        },
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.sync,
          color: Colors.white,
        ),
        tooltip: S.of(context).BlueAudioFileList_k5,
      ),
      body: Obx(
        () {
          // Force rebuild when inputProgressMap changes
          blueController.inputProgressMap;
          return blueController.audioList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.audio_file,
                          size: 48,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        S.of(context).BlueAudioFileList_k3,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: blueController.audioList.length,
                  itemBuilder: (context, index) {
                    final audio = blueController.audioList[index];
                    final wavFileName = getWavFileName(audio.fileName);
                    
                    return Obx(() {
                      final progress = (blueController.inputProgressMap[wavFileName] ?? 0) / 100.0;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.audio_file,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          wavFileName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            progress >= 1.0 ? Colors.green : Colors.blue,
                                          ),
                                          minHeight: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  _buildSyncStatus(progress),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                );
        },
      ),
    );
  }

  Widget _buildSyncButton() {
    return Obx(() {
      bool isSyncing =
      ImportStateEnum.closeSync(blueController.importState.value);
      IconData buttonIcon = isSyncing ? Icons.sync : Icons.sync;
      return Container(
        width: 32,
        height: 32,
        child: TextButton(
          onPressed: blueController.autoImportFile,
          child: Icon(buttonIcon,
              color: isSyncing ? Color(0xFF2196F3) : Color(0xFF666666),
              size: 18),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: isSyncing ? Color(0xFFE3F2FD) : Color(0xFFF5F5F5),
          ),
        ),
      );
    });
  }
}
