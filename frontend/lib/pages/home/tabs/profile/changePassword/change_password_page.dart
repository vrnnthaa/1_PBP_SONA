import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/api/auth/api_user.dart';
import 'package:sona/widgets/input_box.dart';
import 'package:sona/widgets/loading_animation.dart';
import 'package:sona/widgets/utils/alert_success.dart';
import 'package:sona/widgets/confirmation_pop_up.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  final String token;

  const ChangePasswordPage({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _currentError;
  String? _newError;
  String? _confirmError;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Visual error validations and API change password integration
  Future<void> _updatePassword() async {
    setState(() {
      _currentError = null;
      _newError = null;
      _confirmError = null;
    });

    final currentPass = _currentController.text;
    final newPass = _newController.text;
    final confirmPass = _confirmController.text;

    bool isValid = true;

    // 1. Validation: Field cannot be empty (Matches exact mockup error strings)
    if (currentPass.isEmpty) {
      _currentError = 'The current password must not be blank';
      isValid = false;
    }
    if (newPass.isEmpty) {
      _newError = 'The new password must not be blank';
      isValid = false;
    }
    if (confirmPass.isEmpty) {
      _confirmError = 'The confirm new password must not be blank';
      isValid = false;
    }

    // 2. Validation: Strength check guide (mix of letters, numbers, and special characters, length >= 6)
    if (newPass.isNotEmpty) {
      final hasLetter = RegExp(r'[A-Za-z]').hasMatch(newPass);
      final hasDigit = RegExp(r'\d').hasMatch(newPass);
      final hasSpecial = RegExp(r'[@$!%*#?&]').hasMatch(newPass);
      if (newPass.length < 6 || !hasLetter || !hasDigit || !hasSpecial) {
        _newError = 'Password must be at least 6 characters with a mix of letters, numbers, and special characters';
        isValid = false;
      }
    }

    // 3. Validation: Mismatched confirmation password (Matches mockup error string)
    if (newPass.isNotEmpty && confirmPass.isNotEmpty && newPass != confirmPass) {
      _confirmError = 'The new confirmation password does not match the new password';
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
      return;
    }

    final confirmed = await CustomPopUp.showConfirmation(
      context: context,
      title: 'Change Password?',
      subtitle: 'Are you sure you want to change your password?',
    );
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final apiUser = ApiUser();
    final success = await apiUser.changePassword(
      widget.token,
      currentPass,
      newPass,
    );

    if (success) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show bouncy success alert pop-up (AlertSuccess template)
        await AlertSuccess.show(
          context: context,
          title: 'Password Changed!',
          subtitle: 'your security settings have been updated',
          duration: const Duration(seconds: 3),
        );

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Direct error display under Current Password field if API authentication failed
          _currentError = 'Your password is incorrect';
        });
      }
    }
  }

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
            color: AppTheme.deepTeal,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: AppTheme.deepTeal,
            fontSize: 19.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: LoadingAnimation()
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mockup Section Header
                  const Text(
                    'Secure Your Account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2027),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Mockup Section Subtitle
                  Text(
                    'Choose a strong, unique password to keep your hotel bookings and payment details safe',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textGrey,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CURRENT PASSWORD Input box
                  InputBox(
                    label: 'CURRENT PASSWORD',
                    placeholder: 'Enter current password',
                    controller: _currentController,
                    isConfidential: true,
                    errorText: _currentError,
                  ),
                  const SizedBox(height: 24),

                  // NEW PASSWORD Input box
                  InputBox(
                    label: 'NEW PASSWORD',
                    placeholder: 'Create new password',
                    controller: _newController,
                    isConfidential: true,
                    errorText: _newError,
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Must be at least 6 characters with a mix of letters, numbers, and special characters',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textGrey,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CONFIRM NEW PASSWORD Input box
                  InputBox(
                    label: 'CONFIRM NEW PASSWORD',
                    placeholder: 'Repeat new password',
                    controller: _confirmController,
                    isConfidential: true,
                    errorText: _confirmError,
                  ),
                  const SizedBox(height: 40),

                  // Pill-shaped teal button matching mockup exactly
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.deepTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 4,
                        shadowColor: AppTheme.deepTeal.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Update Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
