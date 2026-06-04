import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/widgets/review/review_models.dart';

class ReviewHeaderCard extends StatelessWidget {
  final ReviewHeaderData data;

  const ReviewHeaderCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 76,
              height: 76,
              child: SmartImage(path: data.imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                if (!data.isRoomMode && data.location != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data.location!,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: AppTheme.textTealGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (data.isRoomMode) ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      if (data.guestInfo != null)
                        _MiniInfo(
                          icon: Icons.person_outline_rounded,
                          text: data.guestInfo!,
                        ),
                      if (data.roomSize != null)
                        _MiniInfo(
                          icon: Icons.crop_free_rounded,
                          text: data.roomSize!,
                        ),
                    ],
                  ),
                  if (data.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: data.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textTealGrey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: index < data.rating.round()
                          ? AppTheme.starYellow
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black87),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
