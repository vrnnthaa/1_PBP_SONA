import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/utils/app_theme.dart';

class HotelPoliciesSection extends StatelessWidget {
  final List<HotelPolicy> policies;

  const HotelPoliciesSection({super.key, required this.policies});

  List<HotelPolicy> get _visiblePolicies {
    if (policies.length <= 2) return policies;
    return policies.take(2).toList();
  }

  bool get _hasPolicies => policies.isNotEmpty;

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
        if (_hasPolicies) ...[
          ..._visiblePolicies.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _visiblePolicies.length - 1 ? 0 : 16,
              ),
              child: _buildPolicySection(
                title: section.kategori,
                policies: section.items
                    .map((item) => PolicyItem(text: item))
                    .toList(),
              ),
            );
          }),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: () => _showFullPoliciesBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
        ] else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Policies are not available yet.',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textTealGrey,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Accommodation Policies',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...policies.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == policies.length - 1 ? 0 : 24,
                        ),
                        child: _buildFullPolicySection(
                          title: section.kategori,
                          policies: section.items,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
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
