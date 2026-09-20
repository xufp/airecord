import 'package:airecordapp/db/Cache.dart';
import 'package:airecordapp/util/FileUtil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:airecordapp/l10n/generated/l10n.dart';

class ClearCachePage extends StatefulWidget {
  @override
  State<ClearCachePage> createState() => ClearCachePageState();
}

class ClearCachePageState extends State<ClearCachePage> {
  String _cacheSize = '计算中...';
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF5F7FA),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    _calculateCacheSize();
  }

  Future<void> _calculateCacheSize() async {
    try {
      final size = await FileUtil.getCacheSize();
      setState(() {
        _cacheSize = _formatSize(size);
      });
    } catch (e) {
      setState(() {
        _cacheSize = '计算失败';
      });
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<void> _clearCache() async {
    if (_isClearing) return;
    
    setState(() {
      _isClearing = true;
    });

    try {
      await FileUtil.clearCache();
      await _calculateCacheSize();
      Get.snackbar(
        '提示',
        '缓存清理成功',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '清理缓存失败',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          S.of(context).ClearCachePage_k1,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: Column(
        children: [
          // 缓存信息卡片
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).ClearCachePage_k2,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _cacheSize,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isClearing ? null : _clearCache,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6B8CFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isClearing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            S.of(context).ClearCachePage_k3,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          // 说明文字
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '清除缓存将删除应用内的临时文件，包括下载的音频文件、转写记录等。清除后可能需要重新下载相关文件。',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF999999),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 