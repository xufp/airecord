import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:airecordapp/util/LogUtil.dart';

class FileUtil {
  static final logger = LogUtil.inItLog();

  // 获取缓存大小
  static Future<int> getCacheSize() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      int totalSize = 0;
      
      // 计算音频文件大小
      Directory audioDir = Directory('${appDir.path}/audio');
      if (await audioDir.exists()) {
        totalSize += await _calculateDirectorySize(audioDir);
      }
      
      // 计算临时文件大小
      Directory tempDir = Directory('${appDir.path}/temp');
      if (await tempDir.exists()) {
        totalSize += await _calculateDirectorySize(tempDir);
      }
      
      return totalSize;
    } catch (e) {
      logger.e('计算缓存大小失败: $e');
      return 0;
    }
  }

  // 计算目录大小
  static Future<int> _calculateDirectorySize(Directory dir) async {
    int size = 0;
    try {
      await for (FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      logger.e('计算目录大小失败: $e');
    }
    return size;
  }

  // 清除缓存
  static Future<void> clearCache() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      
      // 清除音频文件
      Directory audioDir = Directory('${appDir.path}/audio');
      if (await audioDir.exists()) {
        await _deleteDirectory(audioDir);
      }
      
      // 清除临时文件
      Directory tempDir = Directory('${appDir.path}/temp');
      if (await tempDir.exists()) {
        await _deleteDirectory(tempDir);
      }
      
      // 清除用户协议和隐私政策缓存
      String lang = await _getSystemLanguage();
      File userAgreementFile = File('${appDir.path}/user_agreement_$lang.json');
      if (await userAgreementFile.exists()) {
        await userAgreementFile.delete();
      }
      
      File privacyPolicyFile = File('${appDir.path}/privacy_policy_$lang.json');
      if (await privacyPolicyFile.exists()) {
        await privacyPolicyFile.delete();
      }
    } catch (e) {
      logger.e('清除缓存失败: $e');
      throw Exception('清除缓存失败');
    }
  }

  // 删除目录及其内容
  static Future<void> _deleteDirectory(Directory dir) async {
    try {
      await for (FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is File) {
          await entity.delete();
        }
      }
      await dir.delete(recursive: true);
    } catch (e) {
      logger.e('删除目录失败: $e');
      throw Exception('删除目录失败');
    }
  }

  // 获取系统语言
  static Future<String> _getSystemLanguage() async {
    // 这里可以根据实际需求获取系统语言
    var locale = Platform.localeName.split('_').first;
    var supported = ['zh', 'en', 'ja', 'ko', 'zh_TW']; // 你的支持语言
    return supported.contains(locale) ? locale : 'en';
    return 'zh'; // 默认返回中文
  }
} 