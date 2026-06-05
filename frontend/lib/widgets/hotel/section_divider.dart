import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(color: AppTheme.borderLight);
  }
}
