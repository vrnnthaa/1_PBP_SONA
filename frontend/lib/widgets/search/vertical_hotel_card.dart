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
  final int? displayPrice;
  final bool isUnavailable;

  const VerticalHotelCard({
    super.key,
    required this.hotel,
    required this.onBookmarkTap,
    required this.onTap,
    this.isBookmarked = false,
    required this.distance,
    this.displayPrice,
    this.isUnavailable = false,
  });

  String _formatPrice(int? price) {
    if (price == null || price <= 0) return 'Price unavailable';

    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final String priceStr = _formatPrice(displayPrice);
    final String fallbackImagePath = 'assets/images/hotel_paradise_resort.jpg';
    final String imagePath = hotel.imagePath ?? fallbackImagePath;

    final String distanceText = distance < 1
        ? '${(distance * 1000).toInt()} m away'
        : '${distance.toStringAsFixed(2)} km away';

    return Opacity(
      opacity: isUnavailable ? 0.82 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.06),
                  blurRadius: 6,
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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            SmartImage(
                              path: imagePath,
                              fit: BoxFit.cover,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            if (isUnavailable)
                              Container(color: Colors.white.withOpacity(0.18)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: onBookmarkTap,
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: BookmarkButton(
                            onTap: onBookmarkTap,
                            isBookmarked: isBookmarked,
                          ),
                        ),
                      ),
                    ),
                    if (isUnavailable)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F1F1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE0D6D6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Fully Booked',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8A7575),
                            ),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                              color: Colors.black,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                                    color: isUnavailable
                                        ? const Color(0xFFFAFAFA)
                                        : Colors.white,
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
                          Expanded(
                            child: isUnavailable
                                ? Text(
                                    'Not available for selected dates',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF8A7575),
                                    ),
                                  )
                                : RichText(
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
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isUnavailable
                                  ? const Color(0xFFF1F3F3)
                                  : AppTheme.buttonLightTeal,
                              foregroundColor: isUnavailable
                                  ? const Color(0xFF8A9495)
                                  : AppTheme.primary,
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
                              isUnavailable ? 'View' : 'Book Now!',
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
        ),
      ),
    );
  }
}
