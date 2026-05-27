import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class SearchCard extends StatelessWidget {
  final TextEditingController locationController;
  final String dateRangeStr;
  final String guestsStr;
  final VoidCallback onTapDates;
  final VoidCallback onTapGuests;
  final VoidCallback onSearchPressed;

  const SearchCard({
    super.key,
    required this.locationController,
    required this.dateRangeStr,
    required this.guestsStr,
    required this.onTapDates,
    required this.onTapGuests,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Location Text Field
          _buildSearchRow(
            icon: Icons.search_rounded,
            child: TextField(
              controller: locationController,
              decoration: const InputDecoration(
                hintText: 'Location',
                hintStyle: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 20, color: AppTheme.borderGrey, thickness: 1.2),
          // Row 2: Date Selector
          _buildSearchRow(
            icon: Icons.calendar_month_outlined,
            onTap: onTapDates,
            child: Text(
              dateRangeStr,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 20, color: AppTheme.borderGrey, thickness: 1.2),
          // Row 3: Guest Selector
          _buildSearchRow(
            icon: Icons.people_outline_rounded,
            onTap: onTapGuests,
            child: Text(
              guestsStr,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Search Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onSearchPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tealDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow({
    required IconData icon,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentTeal, size: 22),
          const SizedBox(width: 14),
          Expanded(child: child),
        ],
      ),
    );
  }
}
