import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButtonWidgets extends StatelessWidget {
  VoidCallback funciton;
  String text;

   CustomButtonWidgets({required this.funciton, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: funciton,
        child: Text(text),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.tealAccent,
            width: 2,
          )
        )
      ),
    );
  }
}
