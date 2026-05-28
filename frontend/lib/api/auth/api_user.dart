import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sona/api/config/api_config.dart';

class ApiUser {
  // 1. Ambil Profil User saat ini
  Future<Map<String, dynamic>> fetchProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/me'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['data']; 
      } else {
        throw Exception('Gagal mengambil data user');
      }
    } catch (e) {
      throw Exception('Gagal mengambil profil user: $e');
    }
  }

  // 2. Update Profil
  Future<bool> updateUserProfile(int idUser, String name, String phone, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/$idUser'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'nama': name,
          'nomor_telp': phone,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 3. Ubah Password
  Future<bool> changePassword(String token, String passwordLama, String passwordBaru) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/change-password'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'password': passwordLama,
          'password_baru': passwordBaru,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}