import 'package:flutter/material.dart';

class AdBannerItemWidget extends StatelessWidget {
  final double width;
  final IconData? icon;
  final String? title;
  final String? imageUrl;
  final VoidCallback onTap;

  AdBannerItemWidget(
      {this.width = 85.0,
      this.icon,
      this.title,
      this.imageUrl,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 40),
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(title!),
              ),
            if (imageUrl != null) Image.asset('assets/images/guangao.png'),
          ],
        ),
      ),
    );
  }
}
