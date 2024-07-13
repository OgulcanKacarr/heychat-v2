import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class FirebaseMessaginService{
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotification() async{
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    print("token: $token");
    initPushNotification();
  }
  void handleMessage(RemoteMessage? message){
    if(message ==null) return;
  }

  Future initPushNotification() async{
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}