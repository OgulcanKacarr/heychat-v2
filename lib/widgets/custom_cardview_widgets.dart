import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCardviewWidgets extends StatelessWidget {

  Container container;

  CustomCardviewWidgets({required this.container});

  @override
  Widget build(BuildContext context) {
    return Card(
      //gölge
      elevation: 50,
      //radius
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(
        color: Colors.purple, width: 3,
      )),
      //gölge rengi
      shadowColor: Colors.purple,
      margin: const EdgeInsets.all(10),
      child: container,
    );
  }
}
