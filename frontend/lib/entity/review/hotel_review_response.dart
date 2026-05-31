import 'package:sona/entity/review/review_model.dart';

class HotelReviewResponse {
  final int idHotel;
  final int totalReview;
  final double averageRating;
  final List<ReviewModel> reviews;

  const HotelReviewResponse({
    required this.idHotel,
    required this.totalReview,
    required this.averageRating,
    required this.reviews,
  });

  factory HotelReviewResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final reviewList = data['reviews'] as List<dynamic>? ?? [];

    return HotelReviewResponse(
      idHotel: data['id_hotel'] ?? 0,
      totalReview: data['total_review'] ?? 0,
      averageRating: (data['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviews: reviewList
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
