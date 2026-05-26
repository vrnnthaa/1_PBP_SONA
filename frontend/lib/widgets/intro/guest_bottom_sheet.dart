import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class GuestBottomSheet extends StatelessWidget {
  final VoidCallback onLoginTap;

  const GuestBottomSheet({
    super.key,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.softCyan,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentTeal.withOpacity(0.08),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.lock_person_rounded,
                color: AppTheme.accentTeal,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Unlock SONA Premium',
            style: TextStyle(
              color: AppTheme.deepTeal,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Register or log in to access this feature, manage bookings, and unlock the full travel dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureRow(Icons.bookmark_added_rounded, 'Save and manage your favorite stays'),
          const SizedBox(height: 10),
          _buildFeatureRow(Icons.receipt_long_rounded, 'View details of your booking history'),
          const SizedBox(height: 10),
          _buildFeatureRow(Icons.location_history_rounded, 'Personalize and edit your travel profile'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onLoginTap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepTeal,
                elevation: 3,
                shadowColor: AppTheme.deepTeal.withOpacity(0.24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Log In / Register Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Maybe Later',
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppTheme.backgroundLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.accentTeal, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
