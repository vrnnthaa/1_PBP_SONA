import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/api/hotel/api_hotel.dart';
import 'package:sona/widgets/search/vertical_hotel_card.dart';

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

  static const bgColor = Color(0xFFF6F7F9);

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
    _showSnackBar('Opening ${hotel.nama} details', false);
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
              decoration: BoxDecoration(
                color: bgColor,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF003A3F).withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFF003A3F).withOpacity(0.04),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF003A3F),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Search Result',
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFF003A3F),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF003A3F).withOpacity(0.08),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1A003A3F),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.location,
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFF003A3F),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_formatDate(widget.checkInDate)} - ${_formatDate(widget.checkOutDate)}, ${widget.guests} guest${widget.guests > 1 ? 's' : ''}',
                              style: GoogleFonts.montserrat(
                                color: const Color(
                                  0xFF003A3F,
                                ).withOpacity(0.55),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${hotels.length} hotel ditemukan di "${widget.location}"',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF003A3F).withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0B9AA4),
                      ),
                    )
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
                              color: const Color(0xFF003A3F),
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
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
