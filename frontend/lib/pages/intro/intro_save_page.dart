import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class IntroSavePage extends StatelessWidget {
  final VoidCallback onExploreTap;

  const IntroSavePage({
    super.key,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Saved Hotels',
          style: TextStyle(
            color: AppTheme.deepTeal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.borderGrey,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/save_image.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Saved Hotels Yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.deepTeal,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hotels you bookmark will appear here. \nStart exploring and save your favorite stays',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                  Container(
                    width: 170,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.softTealGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepTeal.withOpacity(0.24),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: onExploreTap,
                      icon: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 16,
                    ),
                    label: const Text(
                      'Explore Hotel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
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
