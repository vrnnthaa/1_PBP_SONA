import 'package:flutter/material.dart';

class GuestBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GuestBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Background white navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BottomNavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      active: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _BottomNavItem(
                      icon: Icons.bookmark_rounded,
                      label: 'Save',
                      active: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    const SizedBox(width: 60), // Perfectly sized space for center location map button
                    _BottomNavItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'History',
                      active: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                    _BottomNavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      active: currentIndex == 4,
                      onTap: () => onTap(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Central Floating Map/Location Button - standard phone scale (60x60)
          Positioned(
            top: 2,
            child: GestureDetector(
              onTap: () => onTap(2), // Map View is selected at index 2
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: currentIndex == 2
                      ? const Color(0xFF004D52)
                      : const Color(0xFF0B9AA4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: (currentIndex == 2
                              ? const Color(0xFF004D52)
                              : const Color(0xFF0B9AA4))
                          .withOpacity(0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF004D52);
    const Color inactiveColor = Color(0xFF929BA8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Active slide line at the very top of each bottom item column
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: active ? 24 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (!active) const SizedBox(height: 3), // Ensure equal vertical alignment
            Icon(
              icon,
              color: active ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: active ? activeColor : inactiveColor,
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
