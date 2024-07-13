import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:heychat_2/model/message_model.dart';
import 'package:heychat_2/services/firestore_service.dart';
import 'package:heychat_2/utils/constants.dart';

import '../../model/user_model.dart';

class SendAndGetMessagesPageViewmodel extends ChangeNotifier{

  FirestoreService _firestoreService = FirestoreService();
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;


  //Kullanıcının bilgilerini getir
  //Aranan kullanıcının bilgilerini getir
  Future<UserModel?> getUserInfoWithId(BuildContext context, String user_id) async {
    UserModel? user = await _firestoreService.getUserInfoSearchedUser(context, user_id);
    notifyListeners();
    return user;
  }

  void sendNotification() async {
    final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    if (apnsToken != null) {
      final fcmToken = await FirebaseMessaging.instance.getToken();

    }

  }


}