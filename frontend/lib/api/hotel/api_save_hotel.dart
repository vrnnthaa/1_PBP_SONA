import 'dart:convert'; 
import 'package:http/http.dart';
import 'package:sona/api/config/api_config.dart'; 
import 'package:sona/entity/hotel/save_hotel.dart';

class ApiSaveHotel {
  Future<List<SaveHotel>> fetchSavedHotels(int idUser, String token) async {
    try {
      final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/save-hotels?id_user=$idUser'), 
        headers: ApiConfig.getHeaders(token: token), 
      ); 

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body); 
        final List<dynamic> data = jsonResponse['data'] ?? []; 

        return data.map((json) => SaveHotel.fromJson(json)).toList(); 
      } else {
        throw Exception('Gagal memuat daftar hotel tersimpan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e'); 
    }
  }

  /// Create new save/bookmark relation in Laravel database
  Future<bool> saveHotel(int idUser, int idHotel, String token) async {
    try {
      final response = await post(
        Uri.parse('${ApiConfig.baseUrl}/save-hotels'),
        headers: ApiConfig.getHeaders(token: token),
        body: json.encode({
          'id_user': idUser,
          'id_hotel': idHotel,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Toggle/Update existing save hotel status in Laravel database
  Future<bool> toggleSaveHotel(int idSaveHotel, String token) async {
    try {
      final response = await put(
        Uri.parse('${ApiConfig.baseUrl}/save-hotels/$idSaveHotel'),
        headers: ApiConfig.getHeaders(token: token),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
