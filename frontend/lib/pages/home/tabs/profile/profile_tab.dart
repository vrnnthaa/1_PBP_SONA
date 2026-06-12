import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/pages/home/tabs/profile/editProfile/edit_profile_page.dart';
import 'package:sona/pages/home/tabs/profile/changePassword/change_password_page.dart';
import 'package:sona/pages/home/tabs/profile/about/about_page.dart';
import 'package:sona/pages/home/tabs/profile/fingerprint/fingerprint_page.dart';
import 'package:sona/pages/home/tabs/profile/pin/change_pin_page.dart';
import 'package:sona/widgets/loading_animation.dart';

class ProfileTab extends ConsumerStatefulWidget {
  final String? token;
  final VoidCallback onLoginTap;
  final VoidCallback onLogoutTap;

  const ProfileTab({
    super.key,
    required this.token,
    required this.onLoginTap,
    required this.onLogoutTap,
  });

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _isSaving = false;







  // Custom Bullet/Line Password Icon matching mockup
  Widget _buildPasswordIcon() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '•••',
            style: TextStyle(
              color: AppTheme.deepTeal,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 0.8,
            ),
          ),
          const SizedBox(height: 1),
          Container(
            width: 14,
            height: 1.8,
            decoration: BoxDecoration(
              color: AppTheme.deepTeal,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  // Custom Numbers "123"/Line PIN Icon matching mockup
  Widget _build123Icon() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '123',
            style: TextStyle(
              color: AppTheme.deepTeal,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 1),
          Container(
            width: 14,
            height: 1.8,
            decoration: BoxDecoration(
              color: AppTheme.deepTeal,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = widget.token == null || widget.token!.isEmpty;

    // Watch user profile details
    final profileAsync = ref.watch(profileProvider);

    if (_isSaving) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: LoadingAnimation(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Sleek clean white background matching mockup
      body: isGuest
          ? _buildGuestView()
          : profileAsync.when(
              loading: () => const LoadingAnimation(),
              error: (err, stack) => Center(
                child: Text('Error loading profile: $err'),
              ),
              data: (profileData) {
                final String name = profileData?['nama'] ?? '';
                final String email = profileData?['email'] ?? '';
                final String phone = profileData?['telp_no'] ?? '';
                final String photoProfile = profileData?['photo_profile'] ?? '';
                final int idUser = profileData?['id_user'] ?? 1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(isGuest, name, email, phone, photoProfile, idUser, rawProfileData: profileData),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. ACCOUNT SETTINGS Section
                            Text(
                              'ACCOUNT SETTINGS',
                              style: AppTheme.bodyStyle.copyWith(
                                color: AppTheme.textGrey,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMenuTile(
                              context,
                              leading: _buildPasswordIcon(),
                              title: 'Change Password',
                              onTap: () {
                                if (widget.token == null || widget.token!.isEmpty) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangePasswordPage(
                                      token: widget.token!,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildMenuTile(
                              context,
                              leading: _build123Icon(),
                              title: 'Change Secret PIN',
                              onTap: () {
                                if (widget.token == null || widget.token!.isEmpty) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangePinPage(
                                      token: widget.token!,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildMenuTile(
                              context,
                              leading: const Icon(Icons.fingerprint_rounded, color: AppTheme.deepTeal, size: 24),
                              title: 'Finger Print Registration',
                              onTap: () {
                                if (widget.token == null || widget.token!.isEmpty) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FingerprintPage(
                                      token: widget.token!,
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            // 2. SUPPORT & MORE Section
                            Text(
                              'SUPPORT & MORE',
                              style: AppTheme.bodyStyle.copyWith(
                                color: AppTheme.textGrey,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMenuTile(
                              context,
                              leading: const Icon(Icons.info_outline_rounded, color: AppTheme.deepTeal, size: 24),
                              title: 'About',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AboutPage(),
                                  ),
                                );
                              },
                            ),
                            _buildMenuTile(
                              context,
                              leading: const Icon(Icons.logout_rounded, color: Colors.red, size: 24),
                              title: 'Log Out',
                              onTap: widget.onLogoutTap,
                              isDestructive: true,
                              showChevron: false, // No chevron on Log Out matching screenshot
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  // Beautiful Guest view matching the visual curved theme
  Widget _buildGuestView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(true, '', '', '', '', 0),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SUPPORT & MORE',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildMenuTile(
                context,
                leading: const Icon(Icons.info_outline_rounded, color: AppTheme.deepTeal, size: 24),
                title: 'About',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    ),
                  );
                },
              ),
              _buildMenuTile(
                context,
                leading: const Icon(Icons.login_rounded, color: AppTheme.deepTeal, size: 24),
                title: 'Log In / Sign Up',
                onTap: widget.onLoginTap,
                showChevron: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
     // Rebuilt Profile Header with custom ClipPath (ProfileHeaderClipper) to match the curved screenshot
  Widget _buildProfileHeader(bool isGuest, String name, String email, String phone, String photoProfile, int idUser, {Map<String, dynamic>? rawProfileData}) {
    final String defaultHamster = 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=400&q=80';
    final String imagePath = photoProfile.isNotEmpty ? photoProfile : defaultHamster;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24), // Reduced bottom padding since bottom is straight
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F3A3B), // Premium dark teal colors
            Color(0xFF09292A),
          ],
        ),
      ),
      child: Row(
        children: [
          // Circular Profile Photo with floating edit button (now navigates to EditProfilePage)
          GestureDetector(
            onTap: () {
              if (!isGuest && rawProfileData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      profileData: rawProfileData,
                      token: widget.token!,
                    ),
                  ),
                );
              }
            },
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(48),
                    child: (isGuest || photoProfile.isEmpty)
                        ? Container(
                            color: AppTheme.buttonLightTeal,
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppTheme.primary,
                              size: 54,
                              ),
                            )
                        : SmartImage(
                            path: imagePath,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                if (!isGuest)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3D3E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // User Profile Details or Guest Greeting
          Expanded(
            child: isGuest
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Discover Your Dream\nHoliday Experience',
                        style: AppTheme.titleStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: widget.onLoginTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.deepTeal,
                            elevation: 2,
                            shadowColor: Colors.black26,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Log in / Sign up',
                            style: AppTheme.bodyStyle.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name matching mockup exactly (no edit pencil)
                      Text(
                        name.isNotEmpty ? name : 'Guest User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.titleStyle.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Email
                      Text(
                        email.isNotEmpty ? email : 'No email added',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Orders count badge (Matches mockup)
                      Container(
                        width: 76,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '100',
                              style: TextStyle(
                                color: Color(0xFF0C3D3E),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'ORDERS',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 7,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Flat premium menu tile matching screenshot
  Widget _buildMenuTile(
    BuildContext context, {
    required Widget leading,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showChevron = true,
  }) {
    final Color color = isDestructive ? Colors.red : AppTheme.deepTeal;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyStyle.copyWith(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.deepTeal,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }


}



