import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/widgets/home/bookmark_button.dart';

class VerticalHotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;
  final bool isBookmarked;
  final double distance;

  const VerticalHotelCard({
    super.key,
    required this.hotel,
    required this.onBookmarkTap,
    required this.onTap,
    this.isBookmarked = false,
    required this.distance,
  });

  String _formatPrice(int hotelId) {
    final steps = [500, 750, 1000, 1250, 1500, 1750, 2000, 2500];
    final price = steps[hotelId % steps.length];
    if (price >= 1000) {
      final millions = price ~/ 1000;
      final remainder = (price % 1000).toString().padLeft(3, '0');
      return 'Rp $millions.$remainder.000';
    }
    return 'Rp $price.000';
  }

  @override
  Widget build(BuildContext context) {
    final String priceStr = _formatPrice(hotel.id);
    final String fallbackImagePath = 'assets/images/hotel_paradise_resort.jpg';
    final String imagePath = hotel.imagePath ?? fallbackImagePath;

    final String distanceText = distance < 1
        ? '${(distance * 1000).toInt()} m from you'
        : '${distance.toStringAsFixed(2)} km from you';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.10),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.06),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: SmartImage(
                      path: imagePath,
                      fit: BoxFit.cover,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: BookmarkButton(
                      onTap: onBookmarkTap,
                      isBookmarked: isBookmarked,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.nama,
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star_rounded,
                        color: AppTheme.starYellow,
                        size: 18,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        hotel.rating.toStringAsFixed(1),
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppTheme.textTealGrey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${hotel.alamat} | $distanceText',
                          style: GoogleFonts.roboto(
                            color: AppTheme.textTealGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hotel.fasilitas.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 32,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: hotel.fasilitas.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final fasilitas = entry.value;

                            return Container(
                              margin: EdgeInsets.only(
                                right: index == hotel.fasilitas.length - 1
                                    ? 0
                                    : 6,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.borderTealLight,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                fasilitas,
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: AppTheme.textTealMedium,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: priceStr,
                              style: GoogleFonts.montserrat(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                            TextSpan(
                              text: ' / Night',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textTealGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonLightTeal,
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Book Now!',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
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
    );
  }
}
