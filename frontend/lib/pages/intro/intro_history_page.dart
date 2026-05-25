import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class IntroHistoryPage extends StatelessWidget {
  final VoidCallback onExploreTap;

  const IntroHistoryPage({
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
          'History',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/images/history_image.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'No Booking History Yet',
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
                'Your past bookings will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: const BoxDecoration(
                      color: AppTheme.deepTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    'Start exploring and book your first stay',
                    style: TextStyle(
                      color: AppTheme.deepTeal,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  
}
