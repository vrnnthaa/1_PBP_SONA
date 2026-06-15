import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/api/hotel/api_hotel.dart';
import 'package:sona/widgets/loading_animation.dart';
import 'package:sona/widgets/search/vertical_hotel_card.dart';
import 'package:sona/pages/hotels/hotel_detail.dart';

class SearchResultsPage extends StatefulWidget {
  final String location;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;

  const SearchResultsPage({
    super.key,
    required this.location,
    this.checkInDate,
    this.checkOutDate,
    required this.guests,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<Hotel> hotels = [];
  bool isLoading = true;
  Set<int> bookmarkedHotels = {};

  final ApiHotel apiHotel = ApiHotel();
  final Map<int, int> lowestPriceByHotel = {};

  static const Color bgColor = Color(0xFFF3F4F4);
  static const Color primaryColor = Color(0xFF003A3F);
  static const Color secondaryText = Color(0xFF61797B);
  static const Color pillInnerColor = Color(0xFFDDE3E3);

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() => isLoading = true);

    try {
      final loadedHotels = await apiHotel.searchHotelsByLocation(
        widget.location,
      );

      lowestPriceByHotel.clear();

      for (final hotel in loadedHotels) {
        if (hotel.hargaTerendah != null && hotel.hargaTerendah! > 0) {
          lowestPriceByHotel[hotel.id] = hotel.hargaTerendah!;
        }
      }

      loadedHotels.sort((a, b) {
        final aPrice = lowestPriceByHotel[a.id] ?? 999999999;
        final bPrice = lowestPriceByHotel[b.id] ?? 999999999;

        if (aPrice != bPrice) {
          return aPrice.compareTo(bPrice);
        }

        return b.rating.compareTo(a.rating);
      });

      if (!mounted) return;
      setState(() {
        hotels = loadedHotels;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnackBar('Error loading hotels: $e', false);
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return '${date.day} ${_getMonthAbbr(date.month)}';
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
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
      child: Column(
        children: [
          SizedBox(
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
                    'Search Result',
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
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: pillInnerColor,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.location,
                    style: GoogleFonts.montserrat(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(widget.checkInDate)} - ${_formatDate(widget.checkOutDate)}, ${widget.guests} guest${widget.guests > 1 ? 's' : ''}',
                    style: GoogleFonts.montserrat(
                      color: secondaryText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
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
              child: isLoading
                  ? const Center(child: LoadingAnimation())
                  : hotels.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Color(0xFF6B8A8D),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada hotel di\n"${widget.location}"',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba cari lokasi lain',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B8A8D),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
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
                          displayPrice:
                              lowestPriceByHotel[hotel.id] ??
                              hotel.hargaTerendah,
                          isUnavailable: false,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
