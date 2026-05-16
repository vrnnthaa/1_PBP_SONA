import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sona/config/app_config.dart';

class AuthService {

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/login'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }
}