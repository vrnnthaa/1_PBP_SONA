import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/widgets/review/expandable_review_text.dart';
import 'package:sona/widgets/review/review_models.dart';

class ReviewCardItem extends StatelessWidget {
  final ReviewListItemData review;

  const ReviewCardItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final hasImages = review.reviewImages.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8ECEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewHeader(review: review),
          const SizedBox(height: 10),
          ExpandableReviewText(
            text: review.reviewText,
            maxLength: 180,
            textColor: AppTheme.textTealMedium,
            actionColor: const Color(0xFF3B82F6),
            fontSize: 12,
          ),
          if (hasImages) ...[
            const SizedBox(height: 12),
            _ReviewImages(images: review.reviewImages),
          ],
        ],
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  final ReviewListItemData review;

  const _ReviewHeader({required this.review});

  @override
  Widget build(BuildContext context) {
    final subText = review.subLabel == null || review.subLabel!.trim().isEmpty
        ? review.reviewDate
        : '${review.reviewDate} · ${review.subLabel!}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.reviewerName.trim().isEmpty
                    ? 'Anonymous'
                    : review.reviewerName.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textTealGrey,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              size: 16,
              color: AppTheme.starYellow,
            ),
            const SizedBox(width: 2),
            Text(
              review.rating.toStringAsFixed(1),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewImages extends StatelessWidget {
  final List<String> images;

  const _ReviewImages({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: SizedBox(
            width: double.infinity,
            child: SmartImage(path: images.first, fit: BoxFit.cover),
          ),
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: SizedBox(
                width: 280,
                child: SmartImage(path: images[index], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}
