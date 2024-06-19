import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressDialog{
  //Progres Dialog
  static void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
 static void hideProgressDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}