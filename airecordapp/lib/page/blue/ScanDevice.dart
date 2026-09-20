import 'package:flutter/material.dart';

class ScanDevice extends StatefulWidget {
  @override
  _ScanDeviceState createState() => _ScanDeviceState();
}

class _ScanDeviceState extends State<ScanDevice>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(); // 设置动画循环播放
    _animation = Tween<double>(begin: 0, end: 0.5).animate(_controller!);
  }

  @override
  void dispose() {
    _controller!.dispose(); // 动画控制器销毁
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: RadarPainter(_animation!.value),
          ),
        );
      },
    );
  }
}

class RadarPainter extends CustomPainter {
  final double angle;

  RadarPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    //..strokeWidth = 2;

    Offset center = Offset(size.width / 2, size.height / 2);
    double maxRadius = size.width / 2;

    // 绘制雷达圆
    //canvas.drawCircle(center, radius, paint..strokeCap = StrokeCap.round);

    // 绘制多层水波纹圆
    for (int i = 0; i < 3; i++) {
      double radius = maxRadius * (angle + i * 0.2);
      paint.color = Colors.blue.withOpacity(0.5 - i * 0.1); // 逐渐减小透明度
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
