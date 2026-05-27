import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sona/services/api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.body.isEmpty) {
        return {
          'message': 'Server returned an empty response. Please check if your Laravel backend is running.',
          'field': 'both'
        };
      }

      try {
        return jsonDecode(response.body);
      } catch (e) {
        print('Login JSON decoding failed: $e');
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'message': 'Server returned an invalid response. Please check if your Laravel backend is running and database is correctly configured.',
          'field': 'both'
        };
      }
    } catch (e) {
      print('Login connection error: $e');
      return {
        'message': 'Connection error. Please make sure the Laravel backend server is running and accessible.',
        'field': 'both'
      };
    }
  }
}
