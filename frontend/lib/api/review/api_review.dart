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
    required String? photoPath,
    required String token,
  }) async {
    Response response;
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/reviews');
      final request = MultipartRequest('POST', uri);
      
      final headers = ApiConfig.getHeaders(token: token);
      request.headers.addAll(headers);
      request.headers.remove('Content-Type');

      request.fields['id_user'] = idUser.toString();
      request.fields['id_pemesanan'] = idPemesanan.toString();
      request.fields['komentar'] = komentar;
      request.fields['rating'] = rating.toString();

      if (photoPath != null && photoPath.isNotEmpty) {
        request.files.add(
          await MultipartFile.fromPath(
            'photo_review',
            photoPath,
          ),
        );
      }

      final streamedResponse = await request.send();
      response = await Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal membuat review');
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception('Gagal membuat review (Status Code: ${response.statusCode})');
      }
    }
  }
}
