import 'dart:convert';
import 'package:http/http.dart';
import 'package:sona/api/config/api_config.dart';
import 'package:sona/entity/review/hotel_review_response.dart';

class ApiReview {
  Future<HotelReviewResponse> fetchHotelReviews(int idHotel) async {
    try {
      final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/hotel/$idHotel'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return HotelReviewResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Gagal memuat review hotel');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}
