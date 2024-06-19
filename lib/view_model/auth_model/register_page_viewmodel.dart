import 'package:flutter/cupertino.dart';

class RegisterPageViewmodel extends ChangeNotifier{

  void goLoginPage(BuildContext context){
    Navigator.pushNamed(context, "login_page");
  }
}