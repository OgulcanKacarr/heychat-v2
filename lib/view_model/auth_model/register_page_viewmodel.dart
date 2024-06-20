import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:heychat_2/model/user_model.dart';
import 'package:heychat_2/services/auth_service.dart';
import 'package:heychat_2/services/firestore_service.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/utils/progress_dialog.dart';
import 'package:heychat_2/utils/snackbar_util.dart';

class RegisterPageViewmodel extends ChangeNotifier{

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirestoreService _firestoreService = FirestoreService();
  AuthService _authService = AuthService();

  //Login sayfasına git
  void goLoginPage(BuildContext context){
    Navigator.pushNamed(context, "login_page");
  }


  //Kullanıcı oluştur
  Future<void> createUser(
      BuildContext context,
      String email,
      String password,
      String username,
      String nameAndSurname,
      String re_password) async {
    ProgressDialog.showProgressDialog(context);
    if (nameAndSurname.isEmpty == true) {
      SnackbarUtil.showSnackbar(context, Constants.name_and_surname_not_empty);
      ProgressDialog.hideProgressDialog(context);
    } else if (username.isEmpty == true) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.username_not_empty);
    } else if (username.contains(" ")) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.not_use_space);
    } else if (email.isEmpty == true) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.email_is_not_empty);
    } else if (password.isEmpty == true) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.password_is_not_empty);
    } else if (re_password.isEmpty == true) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.re_password_is_not_empty);
    } else if (email.isEmpty == true &&
        password.isEmpty == true &&
        re_password.isEmpty == true) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.enter_info);
    } else if (!password.contains(re_password) ||
        !re_password.contains(password)) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.not_match_password);
    } else {

      //Kullanıcı oluştur ve bilgileri firestore'a ekle
      _authService.createWithEmailAndPassword(context, email, password, username, nameAndSurname).whenComplete((){
        ProgressDialog.hideProgressDialog(context);
        Navigator.pushReplacementNamed(context, "home_page");

      });

    }
    notifyListeners();
  }



}