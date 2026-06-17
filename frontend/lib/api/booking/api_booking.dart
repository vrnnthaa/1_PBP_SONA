import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sona/api/config/api_config.dart';

class ApiBooking {
  Future<List<Map<String, dynamic>>> fetchUserBookings(int idUser, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/pemesanan/user/$idUser'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Pastikan key yang dipanggil tepat
        if (jsonResponse.containsKey('data')) {
          final List<dynamic> rawList = jsonResponse['data'];
          return List<Map<String, dynamic>>.from(rawList);
        }
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  
}
