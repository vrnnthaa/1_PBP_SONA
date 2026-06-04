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
      idHotel: int.tryParse(data['id_hotel'].toString()) ?? 0,
      totalReview: int.tryParse(data['total_review'].toString()) ?? 0,
      averageRating: double.tryParse(data['average_rating'].toString()) ?? 0.0,
      reviews: reviewList
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
