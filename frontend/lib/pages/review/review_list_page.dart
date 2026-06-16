import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/review/review_card_item.dart';
import 'package:sona/widgets/review/review_header_card.dart';
import 'package:sona/widgets/review/review_models.dart';

class ReviewRefreshResult {
  final double averageRating;
  final List<ReviewListItemData> reviews;

  ReviewRefreshResult({
    required this.averageRating,
    required this.reviews,
  });
}

class ReviewListPage extends StatefulWidget {
  final String title;
  final ReviewHeaderData headerData;
  final List<ReviewListItemData> initialReviews;
  final Future<ReviewRefreshResult> Function() onRefresh;

  const ReviewListPage({
    super.key,
    this.title = 'Reviews',
    required this.headerData,
    required this.initialReviews,
    required this.onRefresh,
  });

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  late List<ReviewListItemData> _reviews;
  late ReviewHeaderData _headerData;

  @override
  void initState() {
    super.initState();
    _reviews = widget.initialReviews;
    _headerData = widget.headerData;
  }

  Future<void> _handleRefresh() async {
    try {
      final result = await widget.onRefresh();
      if (!mounted) return;
      setState(() {
        _reviews = result.reviews;
        _headerData = ReviewHeaderData(
          title: _headerData.title,
          imagePath: _headerData.imagePath,
          rating: result.averageRating,
          location: _headerData.location,
          guestInfo: _headerData.guestInfo,
          roomSize: _headerData.roomSize,
          tags: _headerData.tags,
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing reviews: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF3F4F4),
        centerTitle: true,
        title: Text(
          widget.title,
          style: GoogleFonts.montserrat(
            color: AppTheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primary),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
          children: [
            ReviewHeaderCard(data: _headerData),
            const SizedBox(height: 16),
            ..._reviews.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ReviewCardItem(review: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
