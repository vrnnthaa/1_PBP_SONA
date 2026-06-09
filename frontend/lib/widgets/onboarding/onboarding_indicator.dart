import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        totalPages,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentPage == index
                ? AppTheme.backgroundLight
                : AppTheme.textTealMedium,
          ),
        ),
      ),
    );
  }
}