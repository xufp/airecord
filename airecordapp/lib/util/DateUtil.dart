import 'package:intl/intl.dart';

class DateUtil {
  static const YMD_HMS = 'yyyyMMdd_HHmmss';
  static const YMD_CN = 'yyyy年MM月dd日';
  static const YMD_HMS_R = 'yyyy/MM/dd HH:mm';
  static const YMD_HMS_STD = 'yyyy-MM-dd HH:mm:ss';

  static get nowYmdHms {
    var now = DateTime.now();
    var formatter = DateFormat(YMD_HMS);
    return formatter.format(now);
  }

  static get nowYmdCn {
    var now = DateTime.now();
    var formatter = DateFormat(YMD_CN);
    return formatter.format(now);
  }

  static String format(DateTime dateTime, String format) {
    var formatter = DateFormat(format);
    return formatter.format(dateTime);
  }

  static String nowFormat(String format) {
    var now = DateTime.now();
    var formatter = DateFormat(format);
    return formatter.format(now);
  }

  static String formatMillisecond(int time, String format) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    var formatter = DateFormat(format);
    return formatter.format(dateTime);
  }

  static String formatMillisecondToStd(int time) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    var formatter = DateFormat(YMD_HMS_STD);
    return formatter.format(dateTime);
  }

  static String formatSeconds(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    String result = '';
    if (hours > 0) {
      result += hours.toString() + 'h ';
    }
    if (minutes > 0) {
      result += minutes.toString() + 'm ';
    }
    if (seconds > 0) {
      result += seconds.toString() + 's';
    }
    return result;
  }

  static String formatMilliseconds(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int secs = duration.inSeconds % 60;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(secs)}";
    } else {
      return "${twoDigits(minutes)}:${twoDigits(secs)}";
    }
  }


  static String formatPlayerDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes);
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
