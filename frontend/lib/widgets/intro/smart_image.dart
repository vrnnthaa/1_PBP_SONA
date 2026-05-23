import 'package:flutter/material.dart';
import 'package:sona/services/api_service.dart';

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

  // Curated premium Unsplash images matching the layout to make the prototype look gorgeous
  static const Map<String, String> _networkMap = {
    'assets/images/home_hero.jpg':
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=80',
    'assets/images/hotel_paradise_resort.jpg':
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80',
    'assets/images/hotel_buntago.jpg':
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80',
    'assets/images/hotel_sultan.jpg':
        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=600&q=80',
    'assets/images/place_bali.jpg':
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=80',
    'assets/images/place_labuan_bajo.jpg':
        'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?auto=format&fit=crop&w=600&q=80',
    'assets/images/place_lombok.jpg':
        'https://images.unsplash.com/photo-1583212292454-1fe6229603b7?auto=format&fit=crop&w=600&q=80',
    'assets/images/stay_wandala.jpg':
        'https://images.unsplash.com/photo-1517840901100-8179e982acb7?auto=format&fit=crop&w=600&q=80',
    'assets/images/stay_honai.jpg':
        'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&w=600&q=80',
    'assets/images/stay_tenda.jpg':
        'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?auto=format&fit=crop&w=600&q=80',
    'assets/images/stay_tepian.jpg':
        'https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=600&q=80',
    'assets/images/stay_forest.jpg':
        'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?auto=format&fit=crop&w=600&q=80',
    'assets/images/stay_teduh.jpg':
        'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?auto=format&fit=crop&w=600&q=80',
    'assets/images/stay_living.jpg':
        'https://images.unsplash.com/photo-1611891487122-2075b962442f?auto=format&fit=crop&w=600&q=80',
    'assets/images/stay_sentosa.jpg':
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80',
    'assets/images/stay_citra.jpg':
        'https://images.unsplash.com/photo-1529290130-4ca3753253ae?auto=format&fit=crop&w=600&q=80',
  };

  @override
  Widget build(BuildContext context) {
    // Check if the path itself is a direct network URL (database image link)
    final bool isDirectUrl = path.startsWith('http://') || path.startsWith('https://');
    final String? networkUrl = isDirectUrl ? ApiService.normalizeUrl(path) : _networkMap[path];

    Widget imageWidget;
    if (networkUrl != null) {
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B9AA4)),
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
          colors: [Color(0xFFE6F4F4), Color(0xFFB9D6D8)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFF004D52),
          size: 26,
        ),
      ),
    );
  }
}
