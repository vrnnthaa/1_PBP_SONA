import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.primary,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Owl Logo Card
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 90,
                  height: 90,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(),
                  child: Image.asset(
                    'assets/images/sona_logo_with_text.png',
                    width: 90,
                    height: 150,
                    alignment: Alignment.topCenter,
                    fit: BoxFit.fitWidth,
                    color: const Color(0xFFDFFEFF), // Matches secondary color in app theme
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Version 1.0 Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Version 1.0',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // The main card container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppTheme.primary,
                    width: 3.5,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SONA Section
                    const Text(
                      'SONA',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'SONA is a hotel booking application designed to help users find relaxing nature-inspired stays',
                      style: TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // What You Can Do Section
                    const Text(
                      'What You Can Do',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildBulletPoints([
                      'Discover nature-inspired hotels',
                      'Save your favorite stays',
                      'Explore destinations easily',
                      'Manage bookings in one place',
                    ]),

                    const SizedBox(height: 24),

                    // Our Goal Section
                    const Text(
                      'Our Goal',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Helping people find peaceful nature escapes for staycation.',
                      style: TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Footer Text
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'Smooth Online Night Accomodation',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '•••',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBulletPoints(List<String> items) {
    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '• ',
              style: TextStyle(
                color: Color(0xFF4A5568),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(
                  color: Color(0xFF4A5568),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
