import 'package:flutter/cupertino.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


class OneSignelApiService{
  static Future setupOneSignel() async{
    await OneSignal.Notifications.requestPermission(true);
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("<72ab4254-2a63-4a76-9fc4-9e0f724b4b41>");
    }
}