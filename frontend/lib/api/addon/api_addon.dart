import 'dart:convert';
import 'package:http/http.dart';
import 'package:sona/entity/addon/add_on.dart';
import 'package:sona/api/config/api_config.dart';

class ApiAddOn {
  
  Future<List<AddOn>> fetchAddOns() async {
    try {
      final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/addon'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((json) => AddOn.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar add-on');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan : $e');
    }
  }

  Future<List<AddOn>> fetchAddOnsByPemesananId(int idPemesanan) async {
    try {
      final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/addon/pemesanan/$idPemesanan'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((json) => AddOn.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar add-on untuk pemesanan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan : $e');
    }
  }

  Future<AddOn> storeAddOn(
    int idPemesanan,
    String namaAddon,
    double hargaAddon,
    String keteranganAddon,
  ) async {
      try {
        final response = await post(
          Uri.parse('${ApiConfig.baseUrl}/addon'),
          headers: ApiConfig.getHeaders(),
          body: jsonEncode({
            'id_pemesanan': idPemesanan,
            'nama_addon': namaAddon,
            'harga_addon': hargaAddon,
            'keterangan_addon': keteranganAddon,
          }),
        );

        if (response.statusCode == 201) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          final Map<String, dynamic> data = jsonResponse['data'];

          return AddOn.fromJson(data);
        } else {
          throw Exception('Gagal menambahkan add-on');
        }
      } catch (e) {
        throw Exception('Terjadi kesalahan jaringan : $e');
      }
  }
}