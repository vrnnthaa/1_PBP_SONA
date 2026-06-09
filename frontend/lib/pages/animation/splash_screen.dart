
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:sona/pages/home/home_page.dart';
import 'package:sona/utils/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Lottie.asset(
        "assets/Lottie/Splash_Sona.json",
        width: 250,
        height: 250,
      ),
      duration: 6000,
      nextScreen: const HomePage(),
      splashIconSize: 1200,
      backgroundColor: AppTheme.primary,
    );
  }
}