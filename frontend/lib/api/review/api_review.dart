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

  Future<HotelReviewResponse> fetchRoomReviews(int idKamar) async {
    try {
      final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/room/$idKamar'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return HotelReviewResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Gagal memuat review kamar');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  Future<Map<String, dynamic>> createReview({
    required int idUser,
    required int idPemesanan,
    required String komentar,
    required double rating,
    required String? photoUrl,
    required String token,
  }) async {
    try {
      final response = await post(
        Uri.parse('${ApiConfig.baseUrl}/reviews'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({
          'id_user': idUser,
          'id_pemesanan': idPemesanan,
          'komentar': komentar,
          'rating': rating,
          'photo_review': ?photoUrl,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal membuat review');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}
