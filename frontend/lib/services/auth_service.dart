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
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String dateOfBirth,
    required String telp,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/register'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'email': email,
        'password': password,
        'nama': name,
        'tanggal_lahir': dateOfBirth,
        'telp_no': telp,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    return jsonDecode(response.body);
  }
}