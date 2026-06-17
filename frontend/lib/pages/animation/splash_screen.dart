import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:sona/api/config/api_config.dart';
import 'package:sona/pages/auth/set_pin_page.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/pages/home/home_page.dart';
import 'package:sona/pages/auth/login_page.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final Widget nextscreen;
  const SplashScreen({super.key, required this.nextscreen});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRoute();
  }

  Future<void> _checkAndRoute() async {
    await Future.delayed(const Duration(milliseconds: 6000));
    if (!mounted) return;

    final token = ref.read(tokenProvider);

    if (token == null) {
      _go(widget.nextscreen);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/me'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final hasPin = result['has_pin'] == true;

        if (hasPin) {
          _go(const HomePage());
        } else {

          await ref.read(tokenProvider.notifier).clearToken();
          _go(const LoginPage());
        }
      } else {
        await ref.read(tokenProvider.notifier).clearToken();
        _go(widget.nextscreen);
      }
    } catch (e) {
      if (mounted) _go(const LoginPage());
    }
  }

  void _go(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Lottie.asset(
          "assets/Lottie/Splash_Sona.json",
          width: 350,
          height: 350,
          repeat: false,
        ),
      ),
    );
  }
}