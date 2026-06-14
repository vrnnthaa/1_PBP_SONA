import 'dart:convert';

import 'package:http/http.dart';
import 'package:sona/api/config/api_config.dart';
import 'package:sona/entity/review/review_model.dart';

class RoomReviewResponse {
  final int idKamar;
  final double averageRating;
  final int totalReviews;
  final List<ReviewModel> reviews;

  const RoomReviewResponse({
    required this.idKamar,
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  factory RoomReviewResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final reviewList = data['reviews'] as List<dynamic>? ?? [];

    // Backend returns rating as integer, tanggal_review, komentar, and user:{nama}
    // ReviewModel.fromJson already expects nested user map.
    return RoomReviewResponse(
      idKamar: int.tryParse(data['id_kamar']?.toString() ?? '0') ?? 0,
      averageRating:
          double.tryParse(data['average_rating']?.toString() ?? '0') ?? 0.0,
      totalReviews: int.tryParse(data['total_reviews']?.toString() ?? '0') ?? 0,
      reviews: reviewList
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ApiRoomReview {
  Future<RoomReviewResponse> fetchRoomReviews(int idKamar) async {
    try {
      final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/room/$idKamar'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return RoomReviewResponse.fromJson(jsonResponse);
      }

      throw Exception('Gagal memuat review kamar');
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}
