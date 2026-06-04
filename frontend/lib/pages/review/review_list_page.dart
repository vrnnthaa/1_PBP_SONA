import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/review/review_card_item.dart';
import 'package:sona/widgets/review/review_header_card.dart';
import 'package:sona/widgets/review/review_models.dart';

class ReviewListPage extends StatelessWidget {
  final String title;
  final ReviewHeaderData headerData;
  final List<ReviewListItemData> reviews;

  const ReviewListPage({
    super.key,
    this.title = 'Reviews',
    required this.headerData,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF3F4F4),
        centerTitle: true,
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: AppTheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        children: [
          ReviewHeaderCard(data: headerData),
          const SizedBox(height: 16),
          ...reviews.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ReviewCardItem(review: item),
            ),
          ),
        ],
      ),
    );
  }
}
