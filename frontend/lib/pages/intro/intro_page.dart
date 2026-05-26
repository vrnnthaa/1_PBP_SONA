import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/pages/login_page.dart';
import 'package:sona/pages/intro/intro_home_page.dart';
import 'package:sona/pages/intro/intro_save_page.dart';
import 'package:sona/pages/map/map_screen.dart';
import 'package:sona/pages/intro/intro_history_page.dart';
import 'package:sona/pages/intro/intro_profile_page.dart';
import 'package:sona/widgets/intro/guest_bottom_nav.dart';
import 'package:sona/widgets/intro/guest_bottom_sheet.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int _currentTabIndex = 0; // Bottom nav active tab index (0=Home, 1=Save, 2=Map, 3=History, 4=Profile)

  // Navigate to login page
  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Show premium guest action login bottom sheet promo
  void _showGuestPromoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GuestBottomSheet(
        onLoginTap: _openLogin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Render the stand-alone tab screen based on current selection index
          _buildActiveTabContent(),

          // Persistent Interactive Bottom Nav Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: GuestBottomNav(
              currentIndex: _currentTabIndex,
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return IntroHomePage(
          onLoginTap: _openLogin,
          onActionRestricted: _showGuestPromoBottomSheet,
        );
      case 1:
        return IntroSavePage(
          onExploreTap: () {
            setState(() {
              _currentTabIndex = 0;
            });
          },
        );
      case 2:
        return const MapScreen(); // Renders the actual OpenStreetMap screen
      case 3:
        return IntroHistoryPage(
          onExploreTap: () {
            setState(() {
              _currentTabIndex = 0;
            });
          },
        );
      case 4:
        return IntroProfilePage(
          onLoginTap: _openLogin,
        );
      default:
        return const Center(child: Text('Page Not Found'));
    }
  }
}
