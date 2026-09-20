import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class CommonUtil {
  // sha256签名算法
  static Future<String> calculateSHA256(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 整数相除保留两位小数
  static double divideAndFormat(int dividend, int divisor) {
    if (divisor == 0) {
      return 0.00;
    }
    // 执行整数除法，并转换为 double 类型
    double result = (dividend / divisor).toDouble();
    // 使用 toStringAsFixed 方法指定保留的小数位数
    String formattedResult = result.toStringAsFixed(2);
    // 转换回 double 类型并返回
    return double.parse(formattedResult);
  }

  // 整数相除保留整数
  static int divideAndPercentage(int dividend, int divisor) {
    if (divisor == 0) {
      return 0;
    }
    return (dividend * 100) ~/ divisor;
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return '';
    }
  }
}
