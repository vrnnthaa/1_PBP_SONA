import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:sona/utils/app_theme.dart';

class HotelLocationMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String hotelName;
  final String priceText;
  final VoidCallback? onSelectRoomTap;

  const HotelLocationMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.hotelName,
    required this.priceText,
    this.onSelectRoomTap,
  });

  bool get _hasValidCoordinate =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: _hasValidCoordinate
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude, longitude),
                      initialZoom: 16,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        tileProvider: NetworkTileProvider(
                          headers: {
                            'User-Agent':
                                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                          },
                        ),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(latitude, longitude),
                            width: 80,
                            height: 80,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4F8DFD),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x22000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.bed_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4F8DFD),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Container(
                    color: AppTheme.borderLight,
                    alignment: Alignment.center,
                    child: Text(
                      'Location is not available',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textTealGrey,
                      ),
                    ),
                  ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white.withOpacity(0.92),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.primary,
                          size: 28,
                        ),
                      ),
                    ),
                    Text(
                      'Location',
                      style: GoogleFonts.montserrat(
                        color: AppTheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Price starts from\n',
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              color: AppTheme.textTealGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: priceText,
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' / Night',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: AppTheme.textTealGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed:
                          onSelectRoomTap ?? () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buttonLightTeal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                      ),
                      child: Text(
                        'Select Room',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
