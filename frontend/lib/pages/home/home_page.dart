import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/pages/login_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nama = '';
  bool isLoading = true;

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  @override
  void initState() {
    super.initState();

    getProfile();
  }

  Future<void> getProfile() async {

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/me'),

      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final result = jsonDecode(response.body);

    if (!mounted) return;

    setState(() {
      nama = result['data']['nama'];
      isLoading = false;
    });
  }

  Future<void> logout(BuildContext context) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Home'),

        actions: [

          IconButton(
            onPressed: () {
              logout(context);
            },

            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Center(
        child: Text(
          'Hello, $nama',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}