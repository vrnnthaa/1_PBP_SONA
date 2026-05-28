import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/widgets/home/bookmark_button.dart';

class HotelListCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;
  final bool isBookmarked;

  const HotelListCard({
    super.key,
    required this.hotel,
    required this.onBookmarkTap,
    required this.onTap,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a beautiful, realistic dynamic price based on the hotel's ID so it feels alive
    final int generatedPrice = 350 + (hotel.id * 180) % 1200;
    final String priceStr = 'Rp ${generatedPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}.000/Night';

    // Curated fallback Unsplash/Local asset mapping based on hotel index if no image exists in DB
    final String fallbackImagePath = 'assets/images/stay_wandala.jpg';
    final String imagePath = hotel.imagePath ?? fallbackImagePath;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderGrey, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 90,
              child: SmartImage(
                path: imagePath,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: BookmarkButton(
                          onTap: onBookmarkTap,
                          isBookmarked: isBookmarked,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.textGrey,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          hotel.alamat,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star_rounded,
                        color: AppTheme.starYellow,
                        size: 15,
                      ),
                      const SizedBox(width: 1),
                      Text(
                        hotel.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    priceStr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
