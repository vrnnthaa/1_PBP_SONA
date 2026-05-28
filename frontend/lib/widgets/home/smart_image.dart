import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/api/config/api_config.dart';

class SmartImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const SmartImage({
    super.key,
    required this.path,
    required this.fit,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final bool isDirectUrl = path.startsWith('http://') || path.startsWith('https://');

    Widget imageWidget;
    if (isDirectUrl) {
      final String networkUrl = ApiConfig.normalizeUrl(path);
      imageWidget = Image.network(
        networkUrl,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackContainer();
        },
      );
    } else {
      imageWidget = Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackContainer();
        },
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: imageWidget,
    );
  }

  Widget _buildFallbackContainer() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.softCyan, AppTheme.gradientCyanEnd],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppTheme.deepTeal,
          size: 26,
        ),
      ),
    );
  }
}
