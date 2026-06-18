import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sona/utils/app_theme.dart';

/// A helper class to show the custom SVG Confirmation and Success Popups.
class CustomPopUp {
  /// Shows the Confirmation Dialog with customizable title and subtitle.
  /// Returns `true` if "Yes, sure!" is tapped, `false` if "Cancel" is tapped or dismissed.
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    String? subtitle, // Allowed but ignored to keep layout matching original SVG
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Confirmation Dialog',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
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
                child: Container(
                  width: 311,
                  height: 152,
                  decoration: BoxDecoration(
                    color: const Color(0xFF003A3F), // Original SVG fill color
                    borderRadius: BorderRadius.circular(20), // Original SVG rx
                  ),
                  child: Stack(
                    children: [
                      // Centered Title Text
                      Positioned(
                        left: 20,
                        right: 20,
                        top: 28,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      // Cancel Button Tap Target (Left, Red Button)
                      Positioned(
                        left: 24,
                        top: 79,
                        width: 122,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCE031B), // Original SVG red button fill
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Original SVG button rx
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                      // Yes, sure Button Tap Target (Right, White Button)
                      Positioned(
                        left: 165,
                        top: 79,
                        width: 122,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Original SVG white button fill
                            foregroundColor: const Color(0xFF003A3F),
                            elevation: 0,
                            side: const BorderSide(
                              color: Color(0xFF003A3F), // Original SVG button stroke
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Original SVG button rx
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Yes, sure!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
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
