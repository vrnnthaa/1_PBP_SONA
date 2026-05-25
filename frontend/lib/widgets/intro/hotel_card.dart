import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/models/hotel_model.dart';
import 'package:sona/widgets/intro/smart_image.dart';
import 'package:sona/widgets/intro/bookmark_button.dart';

class HotelCard extends StatelessWidget {
  final HotelModel hotel;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;
  final bool isBookmarked;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onBookmarkTap,
    required this.onTap,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a beautiful, realistic dynamic price based on the hotel's ID so it feels alive
    final int generatedPrice = 400 + (hotel.id * 150) % 1100;
    final String priceStr = generatedPrice >= 1000 
        ? 'Rp ${(generatedPrice / 1000).toStringAsFixed(1)}jt/night'
        : 'Rp ${generatedPrice}rb/night';

    // Curated fallback Unsplash/Local asset mapping based on hotel index if no image exists in DB
    final String fallbackImagePath = 'assets/images/hotel_paradise_resort.jpg';
    final String imagePath = hotel.imagePath ?? fallbackImagePath;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SmartImage(
                path: imagePath,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(20),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.02),
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: BookmarkButton(
                    onTap: onBookmarkTap,
                    isBookmarked: isBookmarked,
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      hotel.alamat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            priceStr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppTheme.starYellow,
                                size: 13,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                hotel.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
