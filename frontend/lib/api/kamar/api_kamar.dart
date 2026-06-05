import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:sona/api/config/api_config.dart';
import 'package:sona/entity/kamar/kamar_availability.dart';

class ApiKamar {
  Future<List<KamarAvailability>> fetchAvailableRooms({
    required int idHotel,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guest,
  }) async {
    try {
      final String checkInStr = DateFormat('yyyy-MM-dd').format(checkIn);
      final String checkOutStr = DateFormat('yyyy-MM-dd').format(checkOut);

      final response = await get(
        Uri.parse(
          '${ApiConfig.baseUrl}/hotel/$idHotel/available-rooms'
          '?check_in=$checkInStr&check_out=$checkOutStr&guest=$guest',
        ),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((json) => KamarAvailability.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar kamar');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}
