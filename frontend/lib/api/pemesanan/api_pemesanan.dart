import 'dart:convert';
import 'package:http/http.dart';
import 'package:sona/entity/pemesanan/pemesanan.dart';
import 'package:sona/api/config/api_config.dart';

class ApiPemesanan {
    
    Future<List<Pemesanan>> fetchPemesanan() async {
      try {
        final response = await get(
          Uri.parse('${ApiConfig.baseUrl}/pemesanan'),
          headers: ApiConfig.getHeaders(),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse =jsonDecode(response.body);
          final List<dynamic> data = jsonResponse['data'];

          return data.map((json) => Pemesanan.fromJson(json)).toList();
        }else {
          throw Exception('Gagal memuat daftar pemesanan');
        }

      }catch (e) {
        throw Exception('Terjadi kesalahan jaringan : $e');
      }
    }

    Future<List<Pemesanan>> fetchPemesananByUserId(int idUser) async {
    try {     
        final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/pemesanan/user/$idUser'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((json) => Pemesanan.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar pemesanan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan : $e');
    }
  }

  Future<List<Pemesanan>> fetchPemesananByKamarId(int idKamar) async {
    try {     
        final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/pemesanan/kamar/$idKamar'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((json) => Pemesanan.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar pemesanan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan : $e');
    }
  }

  Future<List<Pemesanan>> fetchPemesananByStatus(String status) async {
    try {     
        final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/pemesanan/status/$status'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((json) => Pemesanan.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar pemesanan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan : $e');
    }
  }

  // POST /pemesanan
  Future<Pemesanan> storePemesanan({
    required int idUser,
    required int idKamar,
    required String checkIn,
    required String checkOut,
    required int jumlahPengunjung,
    required double totalBiaya,
    List<Map<String, dynamic>>? addons,

  }) async {
    try {
      final response = await post(
        Uri.parse('${ApiConfig.baseUrl}/pemesanan'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'id_user': idUser,
          'id_kamar': idKamar,
          'check_in': checkIn,
          'check_out': checkOut,
          'jumlah_pengunjung': jumlahPengunjung,
          'total_biaya': totalBiaya,
          'addons': addons,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        return Pemesanan.fromJson(jsonResponse['data']);
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Gagal membuat pemesanan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  // PUT /pemesanan/{id}
  Future<Pemesanan> updatePemesanan(
    int idPemesanan, {
    int? idUser,
    int? idKamar,
    String? checkIn,
    String? checkOut,
    int? jumlahPengunjung,
    double? totalBiaya,
    String? statusPemesanan,
    List<Map<String, dynamic>>? addons,

  }) async {
    try {
      final Map<String, dynamic> body = {
        if (idUser != null) 'id_user': idUser,
        if (idKamar != null) 'id_kamar': idKamar,
        if (checkIn != null) 'check_in': checkIn,
        if (checkOut != null) 'check_out': checkOut,
        if (jumlahPengunjung != null) 'jumlah_pengunjung': jumlahPengunjung,
        if (totalBiaya != null) 'total_biaya': totalBiaya,
        if (statusPemesanan != null) 'status_pemesanan': statusPemesanan,
        if (addons != null) 'addons': addons,
      };

      final response = await put(
        Uri.parse('${ApiConfig.baseUrl}/pemesanan/$idPemesanan'),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        return Pemesanan.fromJson(jsonResponse['data']);
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Gagal memperbarui pemesanan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  // DELETE /pemesanan/{id}
  Future<void> deletePemesanan(int idPemesanan) async {
    try {
      final response = await delete(
        Uri.parse('${ApiConfig.baseUrl}/pemesanan/$idPemesanan'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Gagal menghapus pemesanan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

}