import 'package:flutter/cupertino.dart';

class LoginPageViewmodel extends ChangeNotifier{

  void goRegisterPage(BuildContext context){
    Navigator.pushNamed(context, "register_page");
  }


}