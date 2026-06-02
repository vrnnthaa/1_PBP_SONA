import 'dart:convert';
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
    final bool isBase64 = path.startsWith('data:image/') || path.contains('base64,') || path.length > 200;

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
    } else if (isBase64) {
      try {
        // Strip data:image/...;base64, prefix if present
        String cleanBase64 = path;
        if (cleanBase64.contains('base64,')) {
          cleanBase64 = cleanBase64.split('base64,').last;
        }
        // Normalize whitespace if any
        cleanBase64 = cleanBase64.trim().replaceAll('\n', '').replaceAll('\r', '');
        
        final bytes = base64Decode(cleanBase64);
        imageWidget = Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackContainer();
          },
        );
      } catch (e) {
        imageWidget = _buildFallbackContainer();
      }
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
