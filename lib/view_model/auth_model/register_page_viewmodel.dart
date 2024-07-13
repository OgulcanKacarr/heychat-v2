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
      String nameAndSurname,
      String username,
      String email,
      String password,
      String re_password
      ) async {
    ProgressDialog.showProgressDialog(context);

    // Trim all input fields to remove unnecessary white spaces
    email = email.trim();
    password = password.trim();
    re_password = re_password.trim();
    username = username.trim();
    nameAndSurname = nameAndSurname.trim();

    if (nameAndSurname.isEmpty) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.name_and_surname_not_empty);
    } else if (username.isEmpty) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.username_not_empty);
    } else if (username.contains(" ")) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.not_use_space);
    } else if (email.isEmpty) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.email_is_not_empty);
    } else if (password.isEmpty) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.password_is_not_empty);
    } else if (re_password.isEmpty) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.re_password_is_not_empty);
    } else if (password != re_password) {
      ProgressDialog.hideProgressDialog(context);
      SnackbarUtil.showSnackbar(context, Constants.not_match_password);
    } else {
      //Kullanıcı oluştur ve bilgileri firestore'a ekle
      _authService.createWithEmailAndPassword(context, email, password, username, nameAndSurname).then((value){
        if(value!.uid != null){
          ProgressDialog.hideProgressDialog(context);
          Navigator.pushReplacementNamed(context, "home_page");
        }else{
          ProgressDialog.hideProgressDialog(context);
        }
      });
    }
    notifyListeners();
  }



}