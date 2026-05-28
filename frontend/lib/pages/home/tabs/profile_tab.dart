import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/api/auth/api_user.dart';
import 'package:sona/providers/app_providers.dart';

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

  Future<void> _editProfile(int idUser, String currentName, String currentPhone) async {
    final token = widget.token;
    if (token == null || token.isEmpty) return;

    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Profile',
          style: AppTheme.titleStyle.copyWith(color: AppTheme.deepTeal, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.deepTeal)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.deepTeal)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isSaving = true;
              });
              
              final apiUser = ApiUser();
              final success = await apiUser.updateUserProfile(
                idUser,
                nameController.text,
                phoneController.text,
                token,
              );
              
              if (success) {
                // Invalidate profile provider to fetch new data reactively across tabs!
                ref.invalidate(profileProvider);
                
                if (mounted) {
                  setState(() {
                    _isSaving = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                  );
                }
              } else {
                if (mounted) {
                  setState(() {
                    _isSaving = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update profile')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Save', style: AppTheme.bodyStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading profile: $err'),
        ),
        data: (profileData) {
          final String name = profileData?['nama'] ?? '';
          final String email = profileData?['email'] ?? '';
          final String phone = profileData?['telp_no'] ?? '';
          final int idUser = profileData?['id_user'] ?? 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(isGuest, name, email, phone),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest ? 'SUPPORT & MORE' : 'ACCOUNT SETTINGS',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isGuest) ...[
                      _buildMenuTile(
                        context,
                        icon: Icons.info_outline_rounded,
                        title: 'About',
                        onTap: () => _showAboutDialog(context),
                      ),
                    ] else ...[
                      _buildMenuTile(
                        context,
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Personal Profile',
                        onTap: () => _editProfile(idUser, name, phone),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuTile(
                        context,
                        icon: Icons.logout_rounded,
                        title: 'Log Out of Account',
                        onTap: widget.onLogoutTap,
                        isDestructive: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(bool isGuest, String name, String email, String phone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.18),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.9), width: 3.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2.5),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.textSlate,
                size: 38,
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.22,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: widget.onLoginTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primary,
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
                      Text(
                        name.isNotEmpty ? name : 'Guest User',
                        style: AppTheme.titleStyle.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email.isNotEmpty ? email : 'No email added',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          phone,
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color color = isDestructive ? AppTheme.errorRed : AppTheme.deepTeal;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.bodyStyle.copyWith(
                      color: isDestructive ? AppTheme.errorRed : AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDestructive ? AppTheme.errorRed.withOpacity(0.5) : AppTheme.textGrey,
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'About SONA',
            style: AppTheme.titleStyle.copyWith(
              color: AppTheme.deepTeal,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SONA - Smooth Online Night Accommodation',
                style: AppTheme.subtitleStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'SONA is a state-of-the-art hotel booking application built to provide premium quality stay bookings with ease and style.',
                style: AppTheme.bodyStyle.copyWith(color: const Color(0xFF5E6573), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Version 1.0.0',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.accentTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
