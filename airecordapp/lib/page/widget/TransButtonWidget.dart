import 'package:flutter/material.dart';

class TransButtonWidget extends StatelessWidget {
  final VoidCallback toggleLoading;

  const TransButtonWidget({Key? key, required this.toggleLoading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleLoading,
      child: Container(
        width: 70.0,
        height: 35.0,
        decoration: BoxDecoration(
          color:
          Color.fromARGB(255, 230, 230, 230), // 淡灰色,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(
            '转写',
            style: TextStyle(
                color: Colors.black, fontSize: 16),
          ),
        ),
      ),
    );
  }
}