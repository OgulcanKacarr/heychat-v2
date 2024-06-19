import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:heychat_2/services/firestore_service.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/utils/snackbar_util.dart';

import '../model/user_model.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirestoreService _firestoreService = FirestoreService();
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //Kullanıcı oluşturma
  Future<User?> createWithEmailAndPassword(BuildContext context, String email,
      String password, String username, String nameAndSurname) async {
    try {
      User? user;
      UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .whenComplete(() {
        //Kullanıcı bilgilerini veritabanını ekle
        UserModel user = UserModel(
            uid: _auth.currentUser!.uid,
            email: email,
            username: username,
            displayName: nameAndSurname,
            isOnline: false);
        _firestoreService.addUserInfoInDatabase(context, user);
      });
      user = result.user;
      return user;
    } on FirebaseAuthException catch (error) {
      if (error.code == "email-already-in-use") {
        SnackbarUtil.showSnackbar(context, Constants.already_email);
      } else if (error.code == "invalid-email") {
        SnackbarUtil.showSnackbar(context, Constants.invalid_email);
      } else if (error.code == "operation-not-allowed") {
        SnackbarUtil.showSnackbar(context, Constants.error);
      } else if (error.code == "weak-password") {
        SnackbarUtil.showSnackbar(context, Constants.wrong_password);
      } else {
        SnackbarUtil.showSnackbar(context, Constants.error);
      }
    }
    return null;
  }

  Future<User?> loginWithEmailAndPassword(BuildContext context, String email,
      String password) async {
    try {
      User? user;
      UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .whenComplete(() {

      });
      user = result.user;
      return user;
    }  on FirebaseAuthException catch (error) {
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

  Future<void> signOut(BuildContext context) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;
      Map<String, dynamic> data = {"isOnline": false};

      await _firebaseFirestore
          .collection(Constants.fb_users)
          .doc(userId)
          .update(data)
          .then((_) async {
        await _auth.signOut().whenComplete((){
          Navigator.pushReplacementNamed(context, "login_page");
        });
      }).catchError((error) {
        print("Failed to update user: $error");
      });
    } else {
      // Kullanıcı zaten çıkış yaptıysa veya null ise, doğrudan giriş sayfasına yönlendirin
      Navigator.pushReplacementNamed(context, "login_page");
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
    Map<String, dynamic> data = {"isOnline": online};
    await _firebaseFirestore
        .collection(Constants.fb_users)
        .doc(uid)
        .update(data);
  }

  Future<void> isOffline(String uid, bool offline) async {
    Map<String, dynamic> data = {"isOnline": offline};
    await _firebaseFirestore
        .collection(Constants.fb_users)
        .doc(uid)
        .update(data);
  }
}
