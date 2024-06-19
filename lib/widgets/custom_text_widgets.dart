import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextWidgets extends StatelessWidget {
  String text;
  double font_size;
  Color color;

   CustomTextWidgets({required this.text, this.font_size = 16, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:  TextStyle(color: color, fontSize: font_size),
    );
  }
}
