import 'package:flutter/material.dart';
import 'package:sona/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/pages/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sona',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004D52)
        )
      ),

      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  
  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    return token != null;
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLogin(),

      builder: (context, snapshot)
      {
        if (snapshot.connectionState == ConnectionState.waiting) {

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if(snapshot.data == true)
        {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}

