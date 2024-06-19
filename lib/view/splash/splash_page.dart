import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:heychat_2/utils/constants.dart';
import 'package:heychat_2/view/auth/login_page.dart';
import 'package:heychat_2/view/home/home_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset(Constants.logo_path),
      nextScreen: LoginPage(),
      splashTransition: SplashTransition.fadeTransition,
      duration: 2000,
    );
  }
}
