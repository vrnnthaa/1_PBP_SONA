import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A helper class to show the custom SVG Confirmation and Success Popups.
class CustomPopUp {
  /// Shows the Confirmation Dialog (Confirmation Pop Up.svg).
  /// Returns `true` if "Yes, sure!" is tapped, `false` if "Cancel" is tapped or dismissed.
  static Future<bool?> showConfirmation({
    required BuildContext context,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Confirmation Dialog',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim, anim2, child) {
        // Bounce / Scale and Fade transition
        final double scale = 0.5 + (0.5 * anim.value);
        final double opacity = anim.value;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Align(
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 311,
                  height: 152,
                  child: Stack(
                    children: [
                      // Render the dialog SVG background
                      SvgPicture.asset(
                        'assets/confirmationDialog/Confirmation Pop Up.svg',
                        width: 311,
                        height: 152,
                      ),
                      // Cancel Button Tap Target (Left, Red Button)
                      Positioned(
                        left: 24,
                        top: 79,
                        width: 122,
                        height: 42,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ),
                      ),
                      // Yes, sure Button Tap Target (Right, White Button)
                      Positioned(
                        left: 165,
                        top: 79,
                        width: 122,
                        height: 42,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows the success dialog and automatically dismisses after a delay.
  /// Supported SVGs: Profile-Success, Password Changes, Secret PIN Changes.
  static Future<void> showSuccess({
    required BuildContext context,
    required String assetPath,
    Duration duration = const Duration(seconds: 3),
  }) {
    bool isClosed = false;

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Success Dialog',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, animation1, animation2) {
        // Automatically dismiss dialog after specified duration
        Future.delayed(duration, () {
          if (!isClosed && Navigator.of(dialogContext).mounted) {
            isClosed = true;
            Navigator.of(dialogContext).pop();
          }
        });
        return const SizedBox.shrink();
      },
      transitionBuilder: (dialogContext, anim, anim2, child) {
        // Elastic / Scale transition for bouncy entry
        final double scale = CurvedAnimation(
          parent: anim,
          curve: Curves.elasticOut,
        ).value;
        final double opacity = anim.value.clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale.isNaN ? 0.0 : scale,
          child: Opacity(
            opacity: opacity,
            child: Align(
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 311,
                  height: 187,
                  child: Stack(
                    children: [
                      // Render the success SVG background
                      SvgPicture.asset(
                        assetPath,
                        width: 311,
                        height: 187,
                      ),
                      // Make the entire popup tappable to dismiss early
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (!isClosed) {
                                isClosed = true;
                                Navigator.of(dialogContext).pop();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
