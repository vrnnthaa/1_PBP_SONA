import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/pages/login_page.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/pages/home/user_home_page.dart';
import 'package:sona/pages/home/user_save_page.dart';
import 'package:sona/pages/map/map_screen.dart';
import 'package:sona/pages/home/user_history_page.dart';
import 'package:sona/pages/home/user_profile_page.dart';
import 'package:sona/widgets/intro/guest_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0; // Persistent active tab index (0=Home, 1=Save, 2=Map, 3=History, 4=Profile)

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
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

          // Persistent Interactive Bottom Nav Bar (Shared with Intro Flow but fully functional!)
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
        return const UserHomePage();
      case 1:
        return UserSavePage(
          onExploreTap: () {
            setState(() {
              _currentTabIndex = 0;
            });
          },
        );
      case 2:
        return const MapScreen(); // Renders the OpenStreetMap screen
      case 3:
        return UserHistoryPage(
          onExploreTap: () {
            setState(() {
              _currentTabIndex = 0;
            });
          },
        );
      case 4:
        return UserProfilePage(
          onLogoutTap: () => _logout(context),
        );
      default:
        return const Center(child: Text('Page Not Found'));
    }
  }
}