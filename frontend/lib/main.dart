import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/api/notification/firebase_api.dart';
import 'package:sona/pages/review/make_review_page.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sona/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sona/pages/animation/splash_screen.dart';
import 'package:sona/pages/onboarding/onboarding_page.dart';
import 'package:sona/api/notification/firebase_api.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://hcpzwjrquqlvqtxowsgt.supabase.co',
      publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhjcHp3anJxdXFsdnF0eG93c2d0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3Njg1MjI5NywiZXhwIjoyMDkyNDI4Mjk3fQ.NVyOZEkgpJQ2SpC6obi2cHwKBBn4VkkzWvkMIptm9ls',
    );
  } catch (e) {
    print("Error initializing Supabase: $e");
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Don't await initNotifications to prevent blocking the main thread / app startup!
    FirebaseApi().initNotifications();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

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

  void _handleInitialNavigation(BuildContext context, Map<String, dynamic> data) {

    final targetScreen = data['screen'];
    final bookingDataRaw = data['booking_data'];
    
    if (targetScreen == 'review_page' && bookingDataRaw != null) {
      try {
        final Map<String, dynamic> bookingMap = jsonDecode(data['booking_data']);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamed(
            '/review-page',
            arguments: bookingMap,
          );
        });
      } catch (e) {
        print("Error parsing initial notification booking data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sona',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004D52)),
        fontFamily: AppTheme.fontPrimary,
      ),
      builder: (context, child) {
        return FutureBuilder(
          future: Future.wait([
            FirebaseMessaging.instance.getInitialMessage(),
            FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails(),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final RemoteMessage? initialMessage = snapshot.data![0];
              if (initialMessage != null && initialMessage.data.isNotEmpty) {
                _handleInitialNavigation(context, initialMessage.data);
              }

              final NotificationAppLaunchDetails? localDetails = snapshot.data![1];
              if (localDetails != null && localDetails.didNotificationLaunchApp) {
                final payloadString = localDetails.notificationResponse?.payload;
                if (payloadString != null) {
                  final Map<String, dynamic> localData = jsonDecode(payloadString);

                  if (localData['data'] != null) {
                    _handleInitialNavigation(context, Map<String, dynamic>.from(localData['data']));
                  }
                }
              } 
            }
            return child ?? const SizedBox.shrink();
          }
        );
      },
      home: const SplashScreen(
        nextscreen: OnboardingPage(),
      ),

      routes: {
        '/review-page': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return MakeReviewPage(booking: args);
        }
      }
    );
  }
}
