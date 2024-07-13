import 'package:flutter/cupertino.dart';
import 'package:heychat_2/services/auth_service.dart';

class HomePageViewmodel extends ChangeNotifier{
  AuthService _authService = AuthService();

  Future<void> signOut(BuildContext context) async{
    await _authService.signOut(context);
    notifyListeners();
  }

}