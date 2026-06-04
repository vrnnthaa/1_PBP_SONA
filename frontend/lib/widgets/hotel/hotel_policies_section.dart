// lib/widgets/hotel/hotel_policies_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/utils/app_theme.dart';

class HotelPoliciesSection extends StatelessWidget {
  const HotelPoliciesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accommodation Policies',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        // Hanya menampilkan Check-in & Check-out
        _buildPolicySection(
          title: 'Check-in & Check-out',
          policies: const [
            PolicyItem(text: 'Check-in time from 14:00', isBold: false),
            PolicyItem(text: 'Check-out time from 12:00', isBold: false),
            PolicyItem(
              text:
                  'Early check-in and late check-out are subject to availability and may incur additional charges.',
              isBold: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Hanya menampilkan Cancellation & Refund
        _buildPolicySection(
          title: 'Cancellation & Refund',
          policies: const [
            PolicyItem(
              text:
                  'Free cancellation is available up to 48 hours before the check-in date.',
              isBold: false,
            ),
            PolicyItem(
              text:
                  'Cancellations made within 48 hours of check-in will be subject to a one-night cancellation fee.',
              isBold: false,
            ),
            PolicyItem(
              text:
                  'No-show reservations will be charged the full booking amount.',
              isBold: false,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: () => _showFullPoliciesBottomSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.buttonLightTeal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'READ ALL',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicySection({
    required String title,
    required List<PolicyItem> policies,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        ...policies.map(
          (policy) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, top: 4),
                      child: const Icon(
                        Icons.circle,
                        size: 4,
                        color: AppTheme.textTealGrey,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: policy.text,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      height: 1.45,
                      fontWeight: policy.isBold
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: policy.isBold
                          ? AppTheme.primary
                          : AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullPoliciesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderTealLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accommodation Policies',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.buttonLightTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFullPolicySection(
                      title: 'Check-in & Check-out',
                      policies: const [
                        'Check-in time from 14:00',
                        'Check-out time from 12:00',
                        'Early check-in and late check-out are subject to availability and may incur additional charges.',
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildFullPolicySection(
                      title: 'Cancellation & Refund',
                      policies: const [
                        'Free cancellation is available up to 48 hours before the check-in date.',
                        'Cancellations made within 48 hours of check-in will be subject to a one-night cancellation fee.',
                        'No-show reservations will be charged the full booking amount.',
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildFullPolicySection(
                      title: 'Room & Stay',
                      policies: const [
                        'A valid ID or passport is required upon check-in.',
                        'A security deposit may be required at check-in and will be refunded upon check-out, subject to room inspection.',
                        'The maximum number of guests per room must not exceed the room\'s stated capacity.',
                        'Extra beds or baby cots are available upon request and subject to availability.',
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            // Safe area untuk menghindari notched display
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFullPolicySection({
    required String title,
    required List<String> policies,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        ...policies.map(
          (policy) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  child: const Icon(
                    Icons.circle,
                    size: 5,
                    color: AppTheme.textTealGrey,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    policy,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PolicyItem {
  final String text;
  final bool isBold;

  const PolicyItem({required this.text, this.isBold = false});
}
