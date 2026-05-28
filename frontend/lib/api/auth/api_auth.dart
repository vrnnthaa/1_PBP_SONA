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

      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return result; // Berisi token dan data user
      } else {
        return {
          'message': result['message'] ?? 'Gagal login',
          'field': result['field'] ?? 'both'
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
  Future<Map<String, dynamic>> register(String nama, String email, String telpNo, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'telp_no': telpNo,
          'password': password,
        }),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return result; // Berisi id_user untuk lanjut ke set PIN
      } else {
        throw Exception(result['message'] ?? 'Gagal register');
      }
    } catch (e) {
      throw Exception('Gagal register: $e');
    }
  }

  // 3. Fungsi Set PIN
  Future<bool> setPin(int idUser, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/set-pin'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'id_user': idUser,
          'pin': pin,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
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