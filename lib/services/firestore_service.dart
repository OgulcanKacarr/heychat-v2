import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:heychat_2/model/user_model.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/utils/snackbar_util.dart';

class FirestoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> addUserInfoInDatabase(BuildContext context, UserModel user) async {
    try {
      await _firebaseFirestore.collection(Constants.fb_users).doc(user.uid).set(user.toFirestore()).whenComplete((){
        //Displayname'i güncelle
        _auth.currentUser!.updateDisplayName(user.displayName);
      });
    } catch (e) {
      SnackbarUtil.showSnackbar(context, " hata oluştu: $e");
    }
  }





}
