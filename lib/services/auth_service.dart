import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:heychat_2/services/firestore_service.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/utils/snackbar_util.dart';

import '../model/user_model.dart';
import '../utils/progress_dialog.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;


  //Kullanıcı oluşturma
  Future<User?> createWithEmailAndPassword(BuildContext context, String email, String password, String username, String nameAndSurname) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Kullanıcı bilgilerini veritabanına ekle
        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          username: username,
          displayName: nameAndSurname,
          isOnline: false,
          token: token
        );
        await _firestoreService.addUserInfoInDatabase(context, userModel);
      }

      return user;
    } on FirebaseAuthException catch (error) {
      if (error.code == "email-already-in-use") {
        ProgressDialog.hideProgressDialog(context);
        SnackbarUtil.showSnackbar(context, Constants.already_email);
      } else if (error.code == "invalid-email") {
        ProgressDialog.hideProgressDialog(context);
        SnackbarUtil.showSnackbar(context, Constants.invalid_email);
      } else if (error.code == "operation-not-allowed") {
        ProgressDialog.hideProgressDialog(context);
        SnackbarUtil.showSnackbar(context, Constants.error);
      } else if (error.code == "weak-password") {
        ProgressDialog.hideProgressDialog(context);
        SnackbarUtil.showSnackbar(context, Constants.wrong_password);
      } else {
        ProgressDialog.hideProgressDialog(context);
        SnackbarUtil.showSnackbar(context, Constants.error);
      }
    } catch (e) {
      SnackbarUtil.showSnackbar(context, e.toString());
    }
    return null;
  }

  //Giriş yap
  Future<User?> loginWithEmailAndPassword(BuildContext context, String email, String password) async {
    User? user;
    try {
      _auth.setLanguageCode('tr');
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user = result.user;
      return user;
    } on FirebaseAuthException catch (error) {
      if (error.code == "account-exists-with-different-credential") {
        SnackbarUtil.showSnackbar(context, Constants.already_email);
      } else if (error.code == "invalid-credential") {
        SnackbarUtil.showSnackbar(context, Constants.wrong_info);
      } else if (error.code == "operation-not-allowed") {
        SnackbarUtil.showSnackbar(context, Constants.error);
      } else if (error.code == "user-disabled") {
        SnackbarUtil.showSnackbar(context, Constants.user_disabled);
      } else if (error.code == "user-not-found") {
        SnackbarUtil.showSnackbar(context, Constants.user_not_found);
      } else if (error.code == "wrong-password") {
        SnackbarUtil.showSnackbar(context, Constants.wrong_password);
      } else {
        SnackbarUtil.showSnackbar(context, Constants.error);
      }
    } catch (error) {
      SnackbarUtil.showSnackbar(context, error.toString());
    }
    return null;
  }


  //Kullanıcı giriş kontrolü
  void currentUser(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      //Kullanıcı daha önce giriş yapmış
      Navigator.pushReplacementNamed(context, "home_page");
    }
  }
  //Kullanıcı auth durumunu kontrol etme
  void initialize() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        isOnline(user.uid, true);
      } else {

      }
    });
  }

  Future<void> isOnline(String uid, bool online) async {
    try {
      Map<String, dynamic> data = {"isOnline": online};
      var userDoc = await _firebaseFirestore.collection(Constants.fb_users).doc(uid).get();
      if (userDoc.exists) {
        await _firebaseFirestore.collection(Constants.fb_users).doc(uid).update(data);
      } else {
        throw Exception('User document not found for $uid');
      }
    } catch (e) {
      print('Error updating isOnline: $e');
      throw e; // İsteğe bağlı olarak hatayı yukarıya iletebilirsiniz
    }
  }

  Future<void> signOut(BuildContext context) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;
      await isOnline(userId, false);
      await _auth.signOut().whenComplete((){
        Navigator.pushReplacementNamed(context, "login_page");
      });
    } else {
      Navigator.pushReplacementNamed(context, "login_page");
    }
  }



}
