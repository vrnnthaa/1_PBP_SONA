import 'dart:convert';
import 'package:http/http.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/api/config/api_config.dart';

class ApiHotel {
  Future<List<Hotel>> fetchHotels() async {
    try {
      final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/hotels'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar hotel');
      }
    } catch (e) {
      throw Exception('Terjaid kesalahan jaringan : $e');
    }
  }

  Future<Hotel> fetchHotelById(int idHotel) async {
    try {
      final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/hotels/$idHotel'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        return Hotel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Hotel tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  Future<List<Hotel>> searchHotelsByLocation(String query) async {
    try {
      final allHotels = await fetchHotels();
      final keyword = query.toLowerCase().trim();

      return allHotels.where((hotel) {
        return hotel.nama.toLowerCase().contains(keyword) ||
            hotel.kota.toLowerCase().contains(keyword) ||
            hotel.alamat.toLowerCase().contains(keyword);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mencari hotel: $e');
    }
  }
}
