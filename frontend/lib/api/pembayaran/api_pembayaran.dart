import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sona/entity/pembayaran/pembayaran.dart';
import 'package:sona/api/config/api_config.dart';

class ApiPembayaran {
  
  // 1. Fetch Semua Pembayaran
  Future<List<Pembayaran>> fetchPembayaran(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/pembayaran'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if(response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? jsonResponse; // Menyesuaikan jika backend melempar langsung array

        return data.map((json) => Pembayaran.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar pembayaran');
      }
    } catch(e) {
      throw Exception('Terjadi kesalahan jaringan : $e');
    }
  }

  // 2. Store / Create Pembayaran
  Future<Pembayaran> storePembayaran({
    required int idPemesanan,
    required DateTime tanggalPembayaran,
    required double jumlahBayar,
    required String statusPembayaran,
    required String metodePembayaran,
    required String token, // Parameter Token
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/pembayaran'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_pemesanan' : idPemesanan,
          // PERBAIKAN: Ubah format ke String (YYYY-MM-DD) agar aman saat di-jsonEncode dan diterima Laravel
          'tanggal_pembayaran' : "${tanggalPembayaran.year}-${tanggalPembayaran.month.toString().padLeft(2, '0')}-${tanggalPembayaran.day.toString().padLeft(2, '0')}",
          'jumlah_bayar' : jumlahBayar,
          'status_pembayaran' : statusPembayaran,
          'metode_pembayaran' : metodePembayaran,
        }),
      );

      if(response.statusCode == 201){
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return Pembayaran.fromJson(jsonResponse['data'] ?? jsonResponse);
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Gagal membuat pembayaran');
      }
    } catch(e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  // 3. Update Status
  Future<Pembayaran> updateStatusPembayaran(
    int idPembayaran, {
    int? idPemesanan,
    DateTime? tanggalPembayaran,
    double? jumlahBayar,
    String? statusPembayaran,
    String? metodePembayaran,
    required String token, // Parameter Token
  }) async {
    try {
      final Map<String, dynamic> body = {
        if (idPemesanan != null) 'id_pemesanan': idPemesanan,
        if (tanggalPembayaran != null) 'tanggal_pembayaran': "${tanggalPembayaran.year}-${tanggalPembayaran.month.toString().padLeft(2, '0')}-${tanggalPembayaran.day.toString().padLeft(2, '0')}",
        if (jumlahBayar != null) 'jumlah_bayar': jumlahBayar,
        if (statusPembayaran != null) 'status_pembayaran': statusPembayaran,
        if (metodePembayaran != null) 'metode_pembayaran': metodePembayaran,
      };

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/pembayaran/$idPembayaran'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if(response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return Pembayaran.fromJson(jsonResponse['data'] ?? jsonResponse);
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Gagal memperbarui pembayaran');
      }
    } catch(e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  // 4. Delete Pembayaran
  Future<bool> deletePembayaran(int idPembayaran, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/pembayaran/$idPembayaran'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Gagal menghapus data pembayaran');
      }
    } catch(e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  // 5. Get Pembayaran Berdasarkan ID Pemesanan
  Future<Pembayaran?> getPembayaranByPemesanan(int idPemesanan, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/pembayaran/pemesanan/$idPemesanan'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return Pembayaran.fromJson(jsonResponse['data'] ?? jsonResponse);
      } else if (response.statusCode == 404) {
        return null; // Mengembalikan null jika belum ada pembayaran untuk pemesanan ini
      } else {
        throw Exception('Gagal mengambil data pembayaran');
      }
    } catch(e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}