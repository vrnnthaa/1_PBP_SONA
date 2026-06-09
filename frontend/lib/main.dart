import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/pages/home/home_page.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sona/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sona/pages/animation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://hcpzwjrquqlvqtxowsgt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhjcHp3anJxdXFsdnF0eG93c2d0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3Njg1MjI5NywiZXhwIjoyMDkyNDI4Mjk3fQ.NVyOZEkgpJQ2SpC6obi2cHwKBBn4VkkzWvkMIptm9ls',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Pre-initialize SharedPreferences synchronously for Riverpod
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sona',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004D52)),
        fontFamily: AppTheme.fontPrimary,
      ),
      home: const SplashScreen(),
    );
  }
}
