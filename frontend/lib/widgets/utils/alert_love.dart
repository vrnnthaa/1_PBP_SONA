import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sona/utils/app_theme.dart';

class AlertLove extends StatelessWidget {
  final String title;
  final String subtitle;

  const AlertLove({
    super.key,
    required this.title,
    required this.subtitle,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    bool isClosed = false;

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Success Dialog',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, animation1, animation2) {
        // Automatically dismiss dialog after specified duration
        Future.delayed(duration, () {
          if (!isClosed && Navigator.of(dialogContext).mounted) {
            isClosed = true;
            Navigator.of(dialogContext).pop();
          }
        });
        
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                if (!isClosed) {
                  isClosed = true;
                  Navigator.of(dialogContext).pop();
                }
              },
              child: AlertLove(
                title: title,
                subtitle: subtitle,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (dialogContext, anim, anim2, child) {
        // Bouncy entry scale transition
        final double scale = CurvedAnimation(
          parent: anim,
          curve: Curves.elasticOut,
        ).value;
        final double opacity = anim.value.clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale.isNaN ? 0.0 : scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 311,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary, // #003A3F
            Color(0xFF0D6D75), // AppTheme.tealMedium / deep teal transition
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Splash Lottie animation with UniqueKey to force restart every time the dialog is shown
          SizedBox(
            width: 100,
            height: 100,
            child: Lottie.asset(
              'assets/Lottie/Luv_That.json',
              key: UniqueKey(),
              repeat: false,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.titleStyle_white.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTheme.subtitleStyle_white.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
