import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class HotelLocationSection extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String hotelName;
  final VoidCallback? onSeeMoreTap;

  const HotelLocationSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.hotelName,
    this.onSeeMoreTap,
  });

  bool get _hasValidCoordinate =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF003A3F),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: _hasValidCoordinate
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude, longitude),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sona.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(latitude, longitude),
                            width: 52,
                            height: 52,
                            child: Tooltip(
                              message: hotelName,
                              child: Center(
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B6F79),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Container(
                    color: const Color(0xFFE8ECEC),
                    alignment: Alignment.center,
                    child: Text(
                      'Location is not available',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7B7C),
                      ),
                    ),
                  ),
          ),
        ),
        if (_hasValidCoordinate && onSeeMoreTap != null) ...[
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: onSeeMoreTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE6E5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'See More on Map',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF003A3F),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
