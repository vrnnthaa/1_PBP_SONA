import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sona/api/config/api_config.dart';

class ApiAuth {
  // 1. Fungsi Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.body.isEmpty) {
        return {
          'message': 'Server returned an empty response. Please check Laravel backend.',
          'field': 'both'
        };
      }

      try {
        return jsonDecode(response.body);
      } catch(e) {
        return {
          'message': 'Gagal login karena koneksi server',
          'field': 'both'
        };
      }
      
    } catch (e) {
      return {
        'message': 'Connection error. Please check Laravel server: $e',
        'field': 'both'
      };
    }
  }

  // 2. Fungsi Register
  Future<Map<String, dynamic>> register(String nama, String email, String tanggal_lahir, String telpNo, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'tanggal_lahir': tanggal_lahir,
          'telp_no': telpNo,
          'password': password,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Gagal register: $e');
    }
  }

  // 3. Fungsi Set PIN
  Future<bool> setPin(String token, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/set-pin'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'pin': pin,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> googleLogin({required String email, required String nama}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/google-auth'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'email': email,
          'nama': nama,
        }),
      );

      print("GOOGLE AUTH STATUS: ${response.statusCode}");
      print("GOOGLE AUTH BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch(e) {
      print('Google login error: $e');
      return null;
    }
  }

  // 4. Fungsi Logout
  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/logout'),
        headers: ApiConfig.getHeaders(token: token),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}