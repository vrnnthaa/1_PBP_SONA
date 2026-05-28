import 'package:flutter/material.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/home/smart_image.dart';

class SavedHotelCard extends StatelessWidget {
  final Hotel hotel;
  final bool showDistance;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const SavedHotelCard({
    super.key,
    required this.hotel,
    this.showDistance = false,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    // Generates a realistic distance (e.g. 2.5 km) for the "Near me" tab based on ID
    final double generatedDistance = 1.5 + (hotel.id * 0.7) % 3.0;

    final String fallbackImagePath = 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&auto=format&fit=crop';
    final String imagePath = hotel.imagePath ?? fallbackImagePath;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Hotel Background Image
              SmartImage(
                path: imagePath,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(24),
              ),
              // 2. Translucent dark gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
              // 3. Top-Left Price Badge
              Positioned(
                left: 16,
                top: 16,
                child: Text(
                  'Rp 1.500.000 / Night', // Matches mockup text
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // 4. Top-Right Bookmark Button
              Positioned(
                right: 16,
                top: 16,
                child: GestureDetector(
                  onTap: onBookmarkTap,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.bookmark_rounded,
                        color: AppTheme.accentTeal,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              // 5. Bottom left info
              Positioned(
                left: 16,
                right: 120, // Leave room for Book Now button
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rating Star Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.starYellow, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            hotel.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Hotel Name
                    Text(
                      hotel.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Address
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white70, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hotel.alamat,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 6. Bottom Right Button (Book Now!) & Optional Distance Badge
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showDistance) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${generatedDistance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Book Now!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
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
