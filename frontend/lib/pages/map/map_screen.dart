import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sona/models/hotel_model.dart';
import 'package:sona/services/api_service.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/pages/login_page.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<HotelModel> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  // Fungsi untuk mengambil data dari Service Laravel
  Future<void> _loadHotels() async {
    final apiService = ApiService();
    final hotels = await apiService.fetchHotels();
    if (mounted) {
      setState(() {
        _hotels = hotels;
        _isLoading = false;
      });
    }
  }

  // Navigate to login page
  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Pop up Bottom Sheet dengan desain premium berukuran HP default
  void _showHotelDetails(HotelModel hotel) {
    // Generate a beautiful, realistic dynamic price based on the hotel's ID so it feels alive
    final int generatedPrice = 350 + (hotel.id * 180) % 1200;
    final String priceStr = 'Rp ${generatedPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}.000/Night';

    // Curated fallback image mapping
    final String fallbackImagePath = 'assets/images/stay_wandala.jpg';
    final String imagePath = hotel.imagePath ?? fallbackImagePath;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Image
                  SizedBox(
                    width: 90,
                    height: 86,
                    child: SmartImage(
                      path: imagePath,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Hotel Info Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              hotel.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on_rounded, color: AppTheme.textGrey, size: 14),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                hotel.alamat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textGrey,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Facilities preview
                        if (hotel.fasilitas.isNotEmpty)
                          SizedBox(
                            height: 18,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: hotel.fasilitas.length > 3 ? 3 : hotel.fasilitas.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 4),
                              itemBuilder: (context, idx) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    hotel.fasilitas[idx].toString(),
                                    style: const TextStyle(
                                      color: AppTheme.deepTeal,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          priceStr,
                          style: const TextStyle(
                            color: AppTheme.accentTeal,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tutup / Book Now Action
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.lightGrey, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Close",
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _openLogin();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Log in to Book",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hotel Maps',
          style: TextStyle(
            color: AppTheme.deepTeal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.borderGrey,
            height: 1,
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepTeal),
            ),
          ) 
        : FlutterMap(
            options: const MapOptions(
              // Center di koordinat area Jogja (sekitar UIN / Muja Muju)
              initialCenter: LatLng(-7.7985, 110.3926),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: _hotels.map((hotel) {
                  return Marker(
                    point: LatLng(hotel.latitude, hotel.longitude),
                    width: 32,
                    height: 32,
                    child: GestureDetector(
                      onTap: () => _showHotelDetails(hotel),
                      child: Container(
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
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
    );
  }
}
