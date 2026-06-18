import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sona/pages/auth/login_page.dart';
import 'package:sona/pages/home/home_page.dart';
import 'package:sona/widgets/green_button.dart';
import 'package:sona/utils/app_theme.dart';

class RegisterSuccessPage extends StatelessWidget {
  final bool isFromRegister;
  
  const RegisterSuccessPage({super.key, this.isFromRegister = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Lottie.asset(
                        'assets/Lottie/SPARKLE.json',
                        repeat: false,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Account Created',
                  style: AppTheme.titleStyle,
                ),

                const SizedBox(height: 8),

                Text(
                  isFromRegister
                      ? 'Your new account has been created,\nlogin to continue'
                      : 'Your PIN has been set,\nwelcome to Sona!',
                  textAlign: TextAlign.center,
                  style: AppTheme.subtitleStyle_teal,
                ),

                const SizedBox(height: 36),

                GreenButton(
                  text: 'Continue',
                  onPressed: () {
                    if (isFromRegister) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}