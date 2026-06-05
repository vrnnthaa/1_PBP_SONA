import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/pages/auth/login_page.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/navigation/guest_bottom_nav.dart';
import 'package:sona/widgets/navigation/guest_bottom_sheet.dart';
import 'package:sona/providers/app_providers.dart';

// New tabs:
import 'package:sona/pages/home/tabs/home_tab.dart';
import 'package:sona/pages/home/tabs/save_tab.dart';
import 'package:sona/pages/home/tabs/map_tab.dart';
import 'package:sona/pages/home/tabs/history_tab.dart';
import 'package:sona/pages/home/tabs/profile/profile_tab.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentTabIndex =
      0; // Persistent active tab index (0=Home, 1=Save, 2=Map, 3=History, 4=Profile)

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showGuestPromoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GuestBottomSheet(onLoginTap: _openLogin),
    );
  }

  Future<void> _logout() async {
    await ref.read(tokenProvider.notifier).clearToken();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    
    final token = ref.watch(tokenProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Render the stand-alone tab screen based on current selection index
          _buildActiveTabContent(token),

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

  Widget _buildActiveTabContent(String? token) {
    switch (_currentTabIndex) {
      case 0:
        return HomeTab(
          token: token,
          onLoginTap: _openLogin,
          onActionRestricted: _showGuestPromoBottomSheet,
        );
      case 1:
        return SaveTab(
          token: token,
          onExploreTap: () {
            setState(() {
              _currentTabIndex = 0;
            });
          },
        );
      case 2:
        return const MapTab(); // Renders the OpenStreetMap screen
      case 3:
        return HistoryTab(
          token: token,
          onExploreTap: () {
            setState(() {
              _currentTabIndex = 0;
            });
          },
        );
      case 4:
        return ProfileTab(
          token: token,
          onLoginTap: _openLogin,
          onLogoutTap: _logout,
        );
      default:
        return const Center(child: Text('Page Not Found'));
    }
  }
}
