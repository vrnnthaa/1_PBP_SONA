import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/utils/app_theme.dart';

class HotelPriceBottomBar extends StatelessWidget {
  final int? price;
  final VoidCallback onSelectRoom;
  final bool isLoading;
  final bool isUnavailable;

  const HotelPriceBottomBar({
    super.key,
    required this.price,
    required this.onSelectRoom,
    this.isLoading = false,
    this.isUnavailable = false,
  });

  String _formatPrice(int? value) {
    if (value == null || value <= 0) return 'Price unavailable';

    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = _formatPrice(price);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.textWhite,
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnavailable
                          ? 'Availability status'
                          : 'Price starts from',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textTealGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (isLoading)
                      Text(
                        'Checking rooms...',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      )
                    else
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: isUnavailable
                                  ? 'Fully booked'
                                  : formattedPrice,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isUnavailable
                                    ? const Color(0xFF8A7575)
                                    : AppTheme.primary,
                              ),
                            ),
                            if (!isUnavailable && price != null && price! > 0)
                              TextSpan(
                                text: ' / Night',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSlate,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSelectRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUnavailable
                        ? const Color(0xFFF1F3F3)
                        : AppTheme.buttonLightTeal,
                    foregroundColor: isUnavailable
                        ? const Color(0xFF8A9495)
                        : AppTheme.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isUnavailable ? 'View Rooms' : 'Select Room',
                    style: GoogleFonts.montserrat(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
