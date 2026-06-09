import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class OnboardingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLastPage;

  const OnboardingButton({
    super.key,
    required this.onPressed,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.tealLight,
        foregroundColor: AppTheme.textWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLastPage ? "Explore Now" : "Next",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}