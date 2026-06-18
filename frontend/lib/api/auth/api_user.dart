// ignore_for_file: use_null_aware_elements

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
  Future<bool> updateUserProfile(int idUser, String name, String phone, String token, {String? photoProfile, String? email, String? tanggalLahir,}) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/$idUser'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'nama': name,
          'nomor_telp': phone,
          if (photoProfile != null) 'photo_profile': photoProfile,
          if (email != null) 'email': email,
          if (tanggalLahir != null) 'tanggal_lahir': tanggalLahir,
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

  // 4. Register Fingerprint
  Future<bool> registerFingerprint(String token, String? fingerprintString) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/change-fingerprint'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'sidik_jari': fingerprintString,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 5. Ubah PIN
  Future<Map<String, dynamic>> changePin(String token, String pinLama, String pinBaru) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/user/change-pin'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'pin_lama': pinLama,
          'pin_baru': pinBaru,
        }),
      );

      final result = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': result['message'] ?? 'Gagal mengubah PIN',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // 6. Verifikasi PIN
  Future<Map<String, dynamic>> verifyPin(String token, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/verify-pin'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'pin': pin,
        }),
      );

      final result = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': result['message'] ?? 'Verifikasi PIN gagal',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

Future<void> saveFcmToken(
    String token,
    String fcmToken,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/save-fcm-token'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fcm_token': fcmToken,
      }),
    );

    print(response.body);
  }
}
