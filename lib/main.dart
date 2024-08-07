

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/services/auth_service.dart';
import 'package:heychat_2/services/firebase_messagin_service.dart';
import 'package:heychat_2/services/one_signel_api_service.dart';
import 'package:heychat_2/utils/custom_theme.dart';
import 'package:heychat_2/view/auth/login_page.dart';
import 'package:heychat_2/view/auth/register_page.dart';
import 'package:heychat_2/view/chats/chats_page.dart';
import 'package:heychat_2/view/chats/send_and_get_messages_page.dart';
import 'package:heychat_2/view/home/home_page.dart';
import 'package:heychat_2/view/post/post_page.dart';
import 'package:heychat_2/view/profile/profile_page.dart';
import 'package:heychat_2/view/request_page/request_page.dart';
import 'package:heychat_2/view/reset_password/reset_password_page.dart';
import 'package:heychat_2/view/search/search_page.dart';
import 'package:heychat_2/view/settings/settings_page.dart';
import 'package:heychat_2/view/splash/splash_page.dart';
import 'package:heychat_2/view/watch_together/watch_together_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


import 'firebase_options.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:
  DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaginService().initNotification();
  AuthService().initialize();
 OneSignelApiService.setupOneSignel();

  runApp(const ProviderScope(child: MainApp()));

}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: CustomTheme.darkTheme,
      theme: CustomTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routes: {
        "splash_page": (context) => SplashPage(),
        "home_page": (context) => HomePage(),
        "register_page": (context) => RegisterPage(),
        "login_page": (context) => LoginPage(),
        "reset_password_page": (context) => ResetPasswordPage(),
        "chats_page": (context) => ChatsPage(),
        "settings_page": (context) => SettingsPage(),
        "profile_page": (context) => ProfilePage(),
        "post_page": (context) => PostPage(),
        "send_message_page": (context) => SendAndGetMessagesPage(),
        "request_page": (context) => RequestPage(),
        "watch_together_page": (context) => WatchTogetherPage(),
      },

      home: SplashPage(),
    );
  }


}
