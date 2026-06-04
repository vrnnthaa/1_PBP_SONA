import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/utils/app_theme.dart';

class ReviewItemData {
  final String reviewerName;
  final String comment;
  final double? rating;
  final bool isSelected;

  const ReviewItemData({
    this.reviewerName = '',
    this.comment = '',
    this.rating,
    this.isSelected = false,
  });

  ReviewItemData copyWith({
    String? reviewerName,
    String? comment,
    double? rating,
    bool? isSelected,
  }) {
    return ReviewItemData(
      reviewerName: reviewerName ?? this.reviewerName,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class HotelReviewsSection extends StatelessWidget {
  final double rating;
  final List<ReviewItemData> reviews;
  final VoidCallback? onViewAllTap;
  final ValueChanged<int>? onReviewTap;
  final int? selectedIndex;
  final int maxVisibleItems;

  const HotelReviewsSection({
    super.key,
    required this.rating,
    required this.reviews,
    this.onViewAllTap,
    this.onReviewTap,
    this.selectedIndex,
    this.maxVisibleItems = 6,
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
    final visibleReviews = reviews.take(maxVisibleItems).toList();

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
                    color: const Color.fromARGB(255, 44, 104, 255),
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
                gradient: _totalReview == 0 ? null : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
                color: _totalReview == 0 ? AppTheme.textTealGrey : null,
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
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: visibleReviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final review = visibleReviews[index];
                final isSelected = selectedIndex != null
                    ? selectedIndex == index
                    : review.isSelected;

                return SizedBox(
                  width: 220,
                  child: ReviewCard(
                    review: review,
                    isSelected: isSelected,
                    onTap: onReviewTap == null
                        ? null
                        : () => onReviewTap!(index),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final ReviewItemData review;
  final bool isSelected;
  final VoidCallback? onTap;

  const ReviewCard({
    super.key,
    required this.review,
    this.isSelected = false,
    this.onTap,
  });

  double get _safeRating {
    final raw = review.rating ?? 0.0;
    if (raw.isNaN) return 0.0;
    return raw.clamp(0.0, 5.0);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppTheme.primary
        : AppTheme.borderTealLight;

    final bgColor = isSelected ? const Color(0xFFF4FAFA) : AppTheme.textWhite;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.comment.trim().isEmpty ? '-' : review.comment.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  height: 1.35,
                  color: AppTheme.textTealMedium,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      review.reviewerName.trim().isEmpty
                          ? 'Anonymous'
                          : review.reviewerName.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}
