// lib/widgets/hotel/hotel_amenity_item.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/utils/app_theme.dart';

class HotelAmenityItem extends StatelessWidget {
  final String label;
  final IconData icon;

  const HotelAmenityItem({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Icon(icon, size: 25, color: AppTheme.textTealGrey),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
