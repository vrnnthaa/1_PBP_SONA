import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sona/api/config/api_config.dart';

class ApiAuth {

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


  Future<Map<String, dynamic>> register(String nama, String email, String tanggalLahir, String telpNo, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'tanggal_lahir': tanggalLahir,
          'telp_no': telpNo,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }


  Future<bool> setPin(String token, String pin, {bool isFromGoogle = false}) async {
    try {
      final url = isFromGoogle
          ? Uri.parse('${ApiConfig.baseUrl}/set-pin?source=google')
          : Uri.parse('${ApiConfig.baseUrl}/set-pin');

      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'pin': pin,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Set Pin Failed: $e');
    }
  }

  Future<Map<String, dynamic>?> googleLogin({required String email, required String nama, String? photoProfile}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/google-auth'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'email': email,
          'nama': nama,
          'photo_profile': photoProfile,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch(e) {
      throw Exception('Sign in with Google failed: $e');
    }
  }


  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/logout'),
        headers: ApiConfig.getHeaders(token: token),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}