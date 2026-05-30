import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/pages/login_page.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/widgets/map_search_bar.dart';
import 'package:sona/pages/hotels/hotel_page.dart';

class MapTab extends ConsumerStatefulWidget {
  const MapTab({super.key});

  @override
  ConsumerState<MapTab> createState() => _MapTabState();
}

class _MapTabState extends ConsumerState<MapTab> {
  Hotel? _selectedHotel;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  String _searchQuery = '';
  bool _showSearchOverlay = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Navigate to login page
  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Show the popup card for the tapped hotel and pan map camera to it
  void _showHotelDetails(Hotel hotel) {
    setState(() {
      _selectedHotel = hotel;
      _showSearchOverlay = false; // Hide search dropdown when focusing a hotel marker
    });
    // Move map camera to focus on this hotel
    _mapController.move(
      LatLng(hotel.latitude, hotel.longitude),
      15.0,
    );
  }

  // Build the premium floating hotel pop-up card overlay (Matches screenshot)
  Widget _buildHotelPopupCard(Hotel hotel) {
    // Generate price in "jt/night" format, e.g. Rp 1,2jt/night matching screenshot
    final int generatedPrice = 350 + (hotel.id * 180) % 1200;
    final String priceStr = 'Rp ${(generatedPrice / 1000).toStringAsFixed(1).replaceAll('.', ',')}jt/night';

    final String fallbackImagePath = 'assets/images/stay_wandala.jpg';
    final String imagePath = hotel.imagePath ?? fallbackImagePath;

    return Container(
      width: 250,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Image
            SmartImage(
              path: imagePath,
              fit: BoxFit.cover,
            ),
            // 2. Translucent dark gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            // 3. Hotel Info Details Overlaid on bottom of image
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Hotel Name
                  Text(
                    hotel.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // City / Location
                  Text(
                    hotel.kota.isNotEmpty ? hotel.kota : 'Yogyakarta',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Bottom Row: Price & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        priceStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            hotel.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 4. Dismiss/Close Button
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedHotel = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the Search Recommendations Overlay Card (No History, ultra-compact, DB-driven facilities)
  Widget _buildSearchOverlayCard(List<Hotel> hotelsList) {
    // Filter hotels for the recommendation section (take top 2)
    final recommendationHotels = hotelsList.take(2).toList();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'RECOMMENDATION HOTELS',
              style: AppTheme.titleStyle.copyWith(
                color: AppTheme.deepTeal,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Recommendation Items
            ...recommendationHotels.map((hotel) {
              final int generatedPrice = 350 + (hotel.id * 180) % 1200;
              final String priceStr = 'Rp ${generatedPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}.000/Night';

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedHotel = hotel;
                    _searchController.text = hotel.nama;
                    _searchQuery = hotel.nama;
                    _showSearchOverlay = false; // Hide dropdown
                  });
                  // Move map camera directly to selected hotel location
                  _mapController.move(
                    LatLng(hotel.latitude, hotel.longitude),
                    15.0
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderGrey, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      // Left Image (More compact)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 68,
                          height: 52,
                          child: SmartImage(
                            path: hotel.imagePath ?? 'assets/images/stay_wandala.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Right Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Row 1: Name and Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    hotel.nama,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.bodyStyle.copyWith(
                                      color: AppTheme.deepTeal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                    const SizedBox(width: 1),
                                    Text(
                                      hotel.rating.toStringAsFixed(1),
                                      style: AppTheme.bodyStyle.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            // Row 2: Location
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: AppTheme.textGrey, size: 10),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    hotel.alamat,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.bodyStyle.copyWith(
                                      color: AppTheme.textGrey,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Row 3: Facilities (Dynamic from database)
                            if (hotel.fasilitas.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: hotel.fasilitas.take(2).map((f) => Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    f,
                                    style: const TextStyle(
                                      color: AppTheme.deepTeal,
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ],
                            
                            const SizedBox(height: 2),
                            // Row 4: Price
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                priceStr,
                                style: AppTheme.bodyStyle.copyWith(
                                  color: AppTheme.deepTeal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Draw the standard marker dot on the map
  Widget _buildMarkerDot(bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.accentTeal.withOpacity(0.18),
      ),
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.accentTeal,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch hotels state dynamically
    final hotelsAsync = ref.watch(hotelsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: hotelsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepTeal),
          ),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading maps: $err'),
        ),
        data: (hotelsList) {
          // Filter hotels dynamically based on search bar query
          final filteredHotels = hotelsList.where((hotel) =>
            hotel.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            hotel.kota.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _showSearchOverlay = false;
              });
            },
            child: Stack(
              children: [
                // 1. Sleek Full-Screen Map
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(-7.7985, 110.3926),
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      tileProvider: NetworkTileProvider(
                        headers: {
                          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                        },
                      ),
                    ),
                    MarkerLayer(
                      markers: filteredHotels.map((hotel) {
                        final isSelected = _selectedHotel?.id == hotel.id;

                        return Marker(
                          point: LatLng(hotel.latitude, hotel.longitude),
                          width: isSelected ? 260.0 : 32.0,
                          height: isSelected ? 165.0 : 32.0,
                          alignment: isSelected ? Alignment.topCenter : Alignment.center,
                          child: isSelected
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Clicking popup card/image redirects to HotelPage
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HotelPage(
                                              location: hotel.alamat,
                                            ),
                                          ),
                                        );
                                      },
                                      child: _buildHotelPopupCard(hotel),
                                    ),
                                    // Small pointing triangle/arrow connecting popup card to dot
                                    CustomPaint(
                                      size: const Size(12, 6),
                                      painter: TrianglePainter(),
                                    ),
                                    const SizedBox(height: 2),
                                    _buildMarkerDot(isSelected),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: () => _showHotelDetails(hotel),
                                  child: _buildMarkerDot(isSelected),
                                ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                // 2. Floating Search Bar Overlay at the top of the map
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  right: 16,
                  child: MapSearchBar(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _showSearchOverlay = value.isNotEmpty;
                      });

                      // If user types a query, check if there is an exact/partial hotel name match
                      if (value.isNotEmpty) {
                        final query = value.toLowerCase();
                        final matchedHotels = hotelsList.where((h) => 
                          h.nama.toLowerCase().contains(query)
                        ).toList();

                        // Automatically close dropdown and fly to that hotel's coordinate on match
                        if (matchedHotels.isNotEmpty) {
                          final matchedHotel = matchedHotels.first;
                          setState(() {
                            _selectedHotel = matchedHotel;
                            _showSearchOverlay = false; // Hide dropdown
                          });
                          _mapController.move(
                            LatLng(matchedHotel.latitude, matchedHotel.longitude), 
                            15.0
                          );
                        }
                      }
                    },
                    onTap: () {
                      setState(() {
                        _showSearchOverlay = true;
                      });
                    },
                  ),
                ),
                // 3. Dropdown Search Recommendations Overlay Card (No History)
                if (_showSearchOverlay)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16 + 54 + 8,
                    left: 16,
                    right: 16,
                    child: _buildSearchOverlayCard(hotelsList),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom Painter to draw a small downward arrow pointing to the marker dot
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.85) // Matches bottom dark gradient of popup card
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
