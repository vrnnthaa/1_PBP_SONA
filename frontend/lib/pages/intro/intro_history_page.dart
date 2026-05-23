import 'package:flutter/material.dart';

class IntroHistoryPage extends StatelessWidget {
  final VoidCallback onExploreTap;

  const IntroHistoryPage({
    super.key,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'History',
          style: TextStyle(
            color: Color(0xFF004D52),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFEFF3F8),
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
              _buildOwlIllustration(context),
              const SizedBox(height: 24),
              const Text(
                'No Booking History Yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF004D52),
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
                  color: Color(0xFF929BA8),
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
                      color: Color(0xFF004D52),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    'Start exploring and book your first stay',
                    style: TextStyle(
                      color: Color(0xFF004D52),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 170,
                height: 44,
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
                    backgroundColor: const Color(0xFF004D52),
                    elevation: 3,
                    shadowColor: const Color(0xFF004D52).withOpacity(0.24),
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

  Widget _buildOwlIllustration(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F4).withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(3, (index) {
            return Positioned(
              left: index == 0 ? 24 : null,
              right: index == 1 ? 12 : null,
              top: index == 2 ? 24 : null,
              bottom: index == 0 ? 18 : null,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B9AA4).withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          Positioned(
            right: 16,
            top: 18,
            child: Icon(
              Icons.insights_rounded,
              color: const Color(0xFF0B9AA4).withOpacity(0.26),
              size: 40,
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B9AA4).withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 22,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOwlEye(),
                      const SizedBox(width: 8),
                      _buildOwlEye(),
                    ],
                  ),
                ),
                Positioned(
                  top: 38,
                  child: Container(
                    width: 8,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC22B),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  child: Container(
                    width: 26,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4F4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF0B9AA4),
                        size: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwlEye() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F4),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0B9AA4), width: 1.2),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF004D52),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
