import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/pages/hotels/hotel_detail.dart';
import 'package:sona/widgets/loading_animation.dart';
import 'package:sona/widgets/search/vertical_hotel_card.dart';
import 'package:sona/api/hotel/api_hotel.dart';

class RecommendedHotelsPage extends StatefulWidget {
  final List<Hotel> hotels;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;
  final String title;

  const RecommendedHotelsPage({
    super.key,
    required this.hotels,
    this.checkInDate,
    this.checkOutDate,
    this.guests = 1,
    this.title = 'Recommended Hotels',
  });

  @override
  State<RecommendedHotelsPage> createState() => _RecommendedHotelsPageState();
}

class _RecommendedHotelsPageState extends State<RecommendedHotelsPage> {
  List<Hotel> hotels = [];
  bool isLoading = true;
  Set<int> bookmarkedHotels = {};
  final Map<int, int> lowestPriceByHotel = {};

  static const Color bgColor = Color(0xFFF3F4F4);
  static const Color primaryColor = Color(0xFF003A3F);

  @override
  void initState() {
    super.initState();
    _prepareHotels();
  }

  Future<void> _prepareHotels() async {
    setState(() => isLoading = true);

    try {
      final sortedHotels = List<Hotel>.from(widget.hotels)
        ..sort((a, b) => a.id.compareTo(b.id));

      lowestPriceByHotel.clear();

      for (final hotel in sortedHotels) {
        if (hotel.hargaTerendah != null && hotel.hargaTerendah! > 0) {
          lowestPriceByHotel[hotel.id] = hotel.hargaTerendah!;
        }
      }

      if (!mounted) return;

      setState(() {
        hotels = sortedHotels;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnackBar('Error loading recommended hotels: $e', false);
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double r = 6371;
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLon = (lon2 - lon1) * (pi / 180);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  void _toggleBookmark(int hotelId) {
    setState(() {
      if (bookmarkedHotels.contains(hotelId)) {
        bookmarkedHotels.remove(hotelId);
        _showSnackBar('Removed from bookmarks', false);
      } else {
        bookmarkedHotels.add(hotelId);
        _showSnackBar('Added to bookmarks', true);
      }
    });
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? const Color(0xFF0B9AA4)
            : const Color(0xFF6B8A8D),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _navigateToDetail(Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelDetailPage(
          hotel: hotel,
          initialBookmarked: bookmarkedHotels.contains(hotel.id),
          checkInDate: widget.checkInDate,
          checkOutDate: widget.checkOutDate,
          guests: widget.guests,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 22,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: primaryColor,
                    size: 32,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Center(
              child: Text(
                widget.title,
                style: GoogleFonts.montserrat(
                  color: primaryColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hotel_outlined, size: 64, color: Color(0xFF6B8A8D)),
          const SizedBox(height: 16),
          Text(
            'No recommended hotels',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try another destination or date',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B8A8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        final hotel = hotels[index];

        final distance = _calculateDistance(
          -8.3405,
          115.0920,
          hotel.latitude,
          hotel.longitude,
        );

        return VerticalHotelCard(
          hotel: hotel,
          distance: distance,
          onBookmarkTap: () => _toggleBookmark(hotel.id),
          onTap: () => _navigateToDetail(hotel),
          isBookmarked: bookmarkedHotels.contains(hotel.id),
          displayPrice: lowestPriceByHotel[hotel.id] ?? hotel.hargaTerendah,
          isUnavailable: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  try {
                    final newHotels = await ApiHotel().fetchHotels();
                    final sortedHotels = List<Hotel>.from(newHotels)
                      ..sort((a, b) => a.id.compareTo(b.id));

                    lowestPriceByHotel.clear();
                    for (final hotel in sortedHotels) {
                      if (hotel.hargaTerendah != null && hotel.hargaTerendah! > 0) {
                        lowestPriceByHotel[hotel.id] = hotel.hargaTerendah!;
                      }
                    }

                    if (mounted) {
                      setState(() {
                        hotels = sortedHotels;
                      });
                    }
                  } catch (e) {
                    _showSnackBar('Error refreshing hotels: $e', false);
                  }
                },
                color: primaryColor,
                child: isLoading
                    ? const Center(child: LoadingAnimation())
                    : hotels.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height - 180,
                              child: _buildEmptyState(),
                            ),
                          )
                        : _buildHotelList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
