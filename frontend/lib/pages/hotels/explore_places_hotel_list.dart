import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/api/hotel/api_hotel.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/pages/hotels/hotel_detail.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/loading_animation.dart';
import 'package:sona/widgets/search/vertical_hotel_card.dart';

// ─── PLACE IMAGE MAP ──────────────────────────────────────────────────────────
const _placeImageMap = {
  'bali': 'assets/images/place_bali.jpg',
  'labuan bajo': 'assets/images/place_labuan_bajo.jpg',
  'lombok': 'assets/images/place_lombok.jpg',
  'yogyakarta': 'assets/images/place_yogyakarta.jpg',
  'anyer': 'assets/images/place_anyer.jpg',
  'bogor': 'assets/images/place_bogor.jpg',
  'bandung': 'assets/images/place_bandung.jpg',
};

class ExplorePlacesHotelListPage extends StatefulWidget {
  final List<Hotel> hotels;
  final String placeName;
  final String? title;

  const ExplorePlacesHotelListPage({
    super.key,
    required this.hotels,
    required this.placeName,
    this.title,
  });

  @override
  State<ExplorePlacesHotelListPage> createState() =>
      _ExplorePlacesHotelListPageState();
}

class _ExplorePlacesHotelListPageState
    extends State<ExplorePlacesHotelListPage> {
  List<Hotel> hotels = [];
  bool isLoading = true;
  Set<int> bookmarkedHotels = {};
  final Map<int, int> lowestPriceByHotel = {};

  @override
  void initState() {
    super.initState();
    _prepareHotels();
  }

  Future<void> _handleRefresh() async {
    try {
      final fetched = await ApiHotel().fetchHotels();
      final filteredHotels = fetched
          .where((hotel) => _matchesPlace(hotel, widget.placeName))
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));

      lowestPriceByHotel.clear();
      for (final hotel in filteredHotels) {
        if (hotel.hargaTerendah != null && hotel.hargaTerendah! > 0) {
          lowestPriceByHotel[hotel.id] = hotel.hargaTerendah!;
        }
      }

      if (!mounted) return;
      setState(() {
        hotels = filteredHotels;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error refreshing places: $e', false);
    }
  }

  Future<void> _prepareHotels() async {
    setState(() => isLoading = true);
    try {
      final filteredHotels =
          widget.hotels
              .where((hotel) => _matchesPlace(hotel, widget.placeName))
              .toList()
            ..sort((a, b) => a.id.compareTo(b.id));

      lowestPriceByHotel.clear();
      for (final hotel in filteredHotels) {
        if (hotel.hargaTerendah != null && hotel.hargaTerendah! > 0) {
          lowestPriceByHotel[hotel.id] = hotel.hargaTerendah!;
        }
      }

      if (!mounted) return;
      setState(() {
        hotels = filteredHotels;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnackBar('Error loading places: $e', false);
    }
  }

  bool _matchesPlace(Hotel hotel, String placeName) {
    final query = placeName.toLowerCase();
    final haystacks = [hotel.kota, hotel.alamat, hotel.nama, hotel.deskripsi];
    if (haystacks.any((v) => v.toLowerCase().contains(query))) return true;
    final aliases = {
      'bali': ['bali'],
      'labuan bajo': ['labuan', 'bajo', 'labuan bajo'],
      'lombok': ['lombok'],
      'yogyakarta': ['yogyakarta', 'jogja', 'yk'],
      'jakarta': ['jakarta'],
      'bandung': ['bandung'],
    };
    final matchingAliases = aliases[query.trim()] ?? <String>[];
    return haystacks.any((v) {
      final l = v.toLowerCase();
      return matchingAliases.any(l.contains);
    });
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
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
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
        content: Text(
          message,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isSuccess ? AppTheme.primary : const Color(0xFF6B8A8D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToDetail(Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HotelDetailPage(hotel: hotel)),
    );
  }

  String get _heroBannerUrl {
    final key = widget.placeName.toLowerCase().trim();
    return _placeImageMap[key] ?? 'assets/images/place_bali.jpg';
  }

  // ── WIDGETS ───────────────────────────────────────────────────────────────

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
      backgroundColor: const Color(0xFFF3F4F4),
      body: isLoading
          ? const Center(child: LoadingAnimation())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppTheme.primary,
              child: _buildScrollBody(),
            ),
    );
  }

  Widget _buildScrollBody() {
    // Total hero height = photo area. The content sheet overlaps by 24px.
    const double heroHeight = 230.0;
    const double overlapOffset = 24.0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero: status bar + top bar + photo, all together ─────────
          SizedBox(
            height: heroHeight,
            child: Stack(
              children: [
                // 1. Full-bleed photo (fills entire hero height)
                Positioned.fill(
                  child: Image.asset(
                    _heroBannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppTheme.primary),
                  ),
                ),

                // 2. Soft gradient overlay — keeps the image vibrant while adding depth
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.35, 0.75, 1.0],
                        colors: [
                          Colors.black.withOpacity(0.28),
                          Colors.black.withOpacity(0.06),
                          Colors.black.withOpacity(0.04),
                          Colors.black.withOpacity(0.18),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Top bar row (back arrow + "Explore Places" title)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Back button
                          Positioned(
                            left: 8,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.pop(context),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Title
                          Text(
                            widget.title ?? 'Explore Places',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Place name + location subtitle (bottom-left)
                Positioned(
                  left: 18,
                  bottom: overlapOffset + 14, // sit above the overlap
                  right: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.placeName,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white70,
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.placeName}, Indonesia',
                            style: GoogleFonts.montserrat(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Content sheet — overlaps hero by overlapOffset ────────────
          Transform.translate(
            offset: const Offset(0, -overlapOffset),
            child: Container(
              // Rounded top corners only — creates the "card sheet" overlap look
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F4),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Small drag indicator (optional, makes it feel like a bottom sheet)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 4),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // ── Hotel list ─────────────────────────────────────────
                  if (hotels.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
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
                ],
              ),
            ),
          ),

          // Compensate for the negative translate so total scroll height is correct
          const SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.buttonLightTeal,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hotel_outlined,
                size: 36,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No stays found',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2E35),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try another destination or check back later',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: const Color(0xFF6B8A8D),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
