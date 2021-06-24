import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  final String text;
  final Color color;

  TextIcon({required this.text, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            Icons.pin_drop,
            color: color,
            size: 30,
          )
        ],
      ),
    );
  }
}
