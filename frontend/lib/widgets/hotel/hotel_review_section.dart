import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/utils/app_theme.dart';

class ReviewItemData {
  final String reviewerName;
  final String comment;
  final double? rating;

  const ReviewItemData({
    this.reviewerName = '',
    this.comment = '',
    this.rating,
  });
}

class HotelReviewsSection extends StatelessWidget {
  final double rating;
  final List<ReviewItemData> reviews;
  final VoidCallback? onViewAllTap;

  const HotelReviewsSection({
    super.key,
    required this.rating,
    required this.reviews,
    this.onViewAllTap,
  });

  double get _safeRating {
    if (rating.isNaN) return 0.0;
    return rating.clamp(0.0, 5.0);
  }

  int get _totalReview => reviews.length;

  String get _ratingLabel {
    if (_totalReview == 0 || _safeRating <= 0) return 'No Reviews';
    if (_safeRating >= 4.5) return 'Excellent';
    if (_safeRating >= 4.0) return 'Very Good';
    if (_safeRating >= 3.0) return 'Good';
    return 'Fair';
  }

  @override
  Widget build(BuildContext context) {
    final visibleReviews = reviews.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            if (_totalReview > 0)
              GestureDetector(
                onTap: onViewAllTap,
                child: Text(
                  'View All',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.starYellow,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _totalReview == 0
                    ? AppTheme.textTealGrey
                    : AppTheme.accentTeal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _totalReview == 0 ? '-' : _safeRating.toStringAsFixed(1),
                style: GoogleFonts.montserrat(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ratingLabel,
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  '$_totalReview review${_totalReview == 1 ? '' : 's'}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11.5,
                    color: AppTheme.textTealGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (visibleReviews.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: visibleReviews.asMap().entries.map((entry) {
              final index = entry.key;
              final review = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == 0 && visibleReviews.length > 1 ? 10 : 0,
                  ),
                  child: ReviewCard(review: review),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewItemData review;

  const ReviewCard({super.key, required this.review});

  double get _safeRating {
    final raw = review.rating ?? 0.0;
    if (raw.isNaN) return 0.0;
    return raw.clamp(0.0, 5.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.textWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderTealLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.comment.trim().isEmpty ? '-' : review.comment.trim(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              height: 1.4,
              color: AppTheme.textTealMedium,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  review.reviewerName.trim().isEmpty
                      ? 'Anonymous'
                      : review.reviewerName.trim(),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              if (review.rating != null) ...[
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppTheme.starYellow,
                ),
                const SizedBox(width: 4),
                Text(
                  _safeRating.toStringAsFixed(1),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
