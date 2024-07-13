import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:heychat_2/services/auth_service.dart';
import 'package:heychat_2/services/firestore_service.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/utils/progress_dialog.dart';
import 'package:heychat_2/utils/snackbar_util.dart';

class LoginPageViewmodel extends ChangeNotifier{

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  void goRegisterPage(BuildContext context){
    Navigator.pushNamed(context, "register_page");
  }
  void goResetPasswordPage(BuildContext context){
    Navigator.pushNamed(context, "reset_password_page");
  }

  Future<void> login(BuildContext context, String email, String password) async {
    ProgressDialog.showProgressDialog(context);
    if (email.isEmpty) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.email_is_not_empty);
    } else if (password.isEmpty) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.password_is_not_empty);
    } else {
      User? user = await _authService.loginWithEmailAndPassword(context, email, password);
      ProgressDialog.hideProgressDialog(context);
      if (user != null) {
        Navigator.pushReplacementNamed(context, "home_page");
      } else {

      }
    }
    notifyListeners();
  }
}
