import 'package:sona/api/review/api_review.dart';
import 'package:sona/entity/review/hotel_review_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewApiServiceProvider = Provider<ApiReview>((ref) {
  return ApiReview();
});

final hotelReviewsProvider = FutureProvider.family<HotelReviewResponse, int>((
  ref,
  hotelId,
) async {
  final service = ref.watch(reviewApiServiceProvider);
  return service.fetchHotelReviews(hotelId);
});
