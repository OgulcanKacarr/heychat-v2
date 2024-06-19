

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heychat_2/utils/custom_theme.dart';
import 'package:heychat_2/view/auth/login_page.dart';
import 'package:heychat_2/view/auth/register_page.dart';
import 'package:heychat_2/view/home/home_page.dart';
import 'package:heychat_2/view/splash/splash_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:
  DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MainApp()));
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: CustomTheme.darkTheme,
      theme: CustomTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routes: {
        "splash_page": (context) => SplashPage(),
        "home_page": (context) => HomePage(),
        "register_page": (context) => RegisterPage(),
        "login_page": (context) => LoginPage(),
      },

      home: SplashPage(),
    );
  }

}
