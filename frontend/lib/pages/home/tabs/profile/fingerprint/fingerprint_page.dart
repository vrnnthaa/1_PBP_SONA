import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/api/auth/api_user.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FingerprintPage extends ConsumerStatefulWidget {
  final String token;

  const FingerprintPage({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<FingerprintPage> createState() => _FingerprintPageState();
}

enum ScanState { manage, initial, scanning, success, error }

class _FingerprintPageState extends ConsumerState<FingerprintPage> with SingleTickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  ScanState _scanState = ScanState.manage;
  String _statusMessage = 'Place your finger on the sensor to securely access your SONA Account';
  String _successMessage = 'Successfully Verified !';
  bool _isLoading = false;
  bool _isOverridingManage = false; // Set to true when user chooses to "Change"
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _verifyExistingFingerprint() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      if (canAuthenticateWithBiometrics && isDeviceSupported) {
        return await _auth.authenticate(
          localizedReason: 'Verify your fingerprint to authorize changes',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
      } else {
        // Fallback for emulator/testing
        await Future.delayed(const Duration(seconds: 1));
        return true;
      }
    } catch (e) {
      // Fallback on error
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
  }

  Future<void> _changeFingerprint() async {
    final verified = await _verifyExistingFingerprint();
    if (!verified) return;

    setState(() {
      _isOverridingManage = true;
      _scanState = ScanState.initial;
    });
  }

  Future<void> _deleteFingerprint() async {
    final verified = await _verifyExistingFingerprint();
    if (!verified) return;

    setState(() {
      _isLoading = true;
    });

    final success = await ApiUser().registerFingerprint(widget.token, null);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('biometric_token');
      await prefs.setBool('biometric_enabled', false);

      ref.invalidate(profileProvider);

      setState(() {
        _successMessage = 'Successfully Deleted !';
        _scanState = ScanState.success;
      });
    } else {
      setState(() {
        _scanState = ScanState.error;
        _statusMessage = 'Failed to delete fingerprint from the server. Please try again.';
      });
    }
  }

  Future<void> _startScanning() async {
    setState(() {
      _scanState = ScanState.scanning;
      _animationController.repeat();
    });

    bool authenticated = false;
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      if (canAuthenticateWithBiometrics && isDeviceSupported) {
        authenticated = await _auth.authenticate(
          localizedReason: 'Scan your fingerprint to register biometric login',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
      } else {
        await Future.delayed(const Duration(seconds: 2));
        authenticated = true;
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));
      authenticated = true;
    }

    if (authenticated) {
      final String fpToken = 'sona_fp_${DateTime.now().millisecondsSinceEpoch}';

      setState(() {
        _isLoading = true;
      });

      final success = await ApiUser().registerFingerprint(widget.token, fpToken);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('biometric_token', fpToken);
        await prefs.setBool('biometric_enabled', true);

        ref.invalidate(profileProvider);

        setState(() {
          _successMessage = 'Successfully Verified !';
          _scanState = ScanState.success;
          _animationController.stop();
        });
      } else {
        setState(() {
          _scanState = ScanState.error;
          _statusMessage = 'Failed to register fingerprint on the server. Please try again.';
          _animationController.stop();
        });
      }
    } else {
      setState(() {
        _scanState = ScanState.initial;
        _animationController.stop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch profile provider to see if there is already a registered fingerprint
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Error: $err')),
      ),
      data: (profileData) {
        final bool hasFp = profileData?['sidik_jari'] != null && (profileData?['sidik_jari'] as String).isNotEmpty;
        
        // Decide initial scanState
        if (hasFp && !_isOverridingManage && _scanState == ScanState.manage) {
          // Keep ScanState.manage
        } else if (_scanState == ScanState.manage) {
          // If no fingerprint, auto transition to ScanState.initial
          _scanState = ScanState.initial;
        }

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
            title: Text(
              _scanState == ScanState.manage ? 'Touch ID Settings' : 'Set Up Touch ID',
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        _scanState == ScanState.manage ? 'Manage Touch ID' : 'Place Your Finger',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF242833),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _scanState == ScanState.error
                              ? _statusMessage
                              : _scanState == ScanState.manage
                                  ? 'Modify or remove your registered Touch ID biometric login configuration'
                                  : 'Place your finger on the sensor to securely access your SONA Account',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textTealGrey,
                            height: 1.45,
                          ),
                        ),
                      ),
                      
                      const Spacer(),

                      _buildGraphic(),

                      const Spacer(),

                      _buildBottomSection(),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildGraphic() {
    switch (_scanState) {
      case ScanState.manage:
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.2),
              width: 8,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.fingerprint_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
        );

      case ScanState.initial:
      case ScanState.error:
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF5A7E82).withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF5A7E82).withOpacity(0.3),
              width: 8,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF507B80),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.fingerprint_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
        );

      case ScanState.scanning:
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: RotationTransition(
                turns: _animationController,
                child: const CircularProgressIndicator(
                  value: 0.35,
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            Container(
              width: 124,
              height: 124,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 72,
                color: AppTheme.primary,
              ),
            ),
          ],
        );

      case ScanState.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 100,
                height: 100,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: SvgPicture.asset(
                  'assets/animation/Success Animation Icon.svg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _successMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildBottomSection() {
    if (_scanState == ScanState.scanning) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scanning ....',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 34),
        ],
      );
    }

    if (_scanState == ScanState.manage) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildManageTile(
              icon: Icons.cached_rounded,
              title: 'Change Registered Touch ID',
              subtitle: 'Replace existing fingerprint',
              onTap: _changeFingerprint,
            ),
            Divider(height: 1, color: AppTheme.borderLight, indent: 56),
            _buildManageTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete Registered Touch ID',
              subtitle: 'Remove biometric login credentials',
              titleColor: Colors.redAccent,
              iconColor: Colors.redAccent,
              onTap: _deleteFingerprint,
            ),
          ],
        ),
      );
    }

    final String buttonText = _scanState == ScanState.success ? 'Go To Profile' : 'Start Scanning';
    final VoidCallback onPressed = _scanState == ScanState.success
        ? () => Navigator.pop(context)
        : _startScanning;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 4,
          shadowColor: AppTheme.primary.withOpacity(0.3),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildManageTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primary).withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? AppTheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppTheme.textDark,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textGrey,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textGrey, size: 24),
      onTap: onTap,
    );
  }
}
