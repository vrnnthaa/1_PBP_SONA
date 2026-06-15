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
      final checkInStr = DateFormat('yyyy-MM-dd').format(checkIn);
      final checkOutStr = DateFormat('yyyy-MM-dd').format(checkOut);

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/hotel/$idHotel/available-rooms'
        '?check_in=$checkInStr&check_out=$checkOutStr&guest=$guest',
      );

      final response = await get(uri, headers: ApiConfig.getHeaders());

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat daftar kamar (${response.statusCode})');
      }

      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      final rawData = jsonResponse['data'];
      final List data = rawData is List ? rawData : [];

      return data
          .map(
            (item) => KamarAvailability.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}
