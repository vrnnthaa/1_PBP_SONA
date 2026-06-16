import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/entity/intro_models.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/widgets/home/hotel_card.dart';
import 'package:sona/widgets/home/place_card.dart';
import 'package:sona/widgets/home/hotel_list_card.dart';
import 'package:sona/widgets/home/category_tabs.dart';
import 'package:sona/widgets/home/search_card.dart';
import 'package:sona/pages/hotels/hotel_detail.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/pages/search/search_results_page.dart';
import 'package:sona/widgets/search/date_range_popup.dart';
import 'package:sona/widgets/loading_animation.dart';
import 'package:sona/pages/hotels/recommended_hotels_page.dart';
import 'package:sona/pages/hotels/explore_places_hotel_list.dart';
import 'package:sona/pages/home/viewall_explore_place.dart';

class HomeTab extends ConsumerStatefulWidget {
  final String? token;
  final VoidCallback onLoginTap;
  final VoidCallback onActionRestricted;

  const HomeTab({
    super.key,
    required this.token,
    required this.onLoginTap,
    required this.onActionRestricted,
  });

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  int _selectedCategoryIndex = 0;
  String _deviceLocation =
      'Yogyakarta, Indonesia'; // Dynamic device location fallback

  final List<PlaceData> _places = const [
    PlaceData(name: 'Bali', imagePath: 'assets/images/place_bali.jpg'),
    PlaceData(
      name: 'Labuan Bajo',
      imagePath: 'assets/images/place_labuan_bajo.jpg',
    ),
    PlaceData(name: 'Lombok', imagePath: 'assets/images/place_lombok.jpg'),
    PlaceData(
      name: 'Yogyakarta',
      imagePath: 'assets/images/place_yogyakarta.jpg',
    ),
  ];

  void _navigateToRecommendedPage(List<Hotel> recommendedHotels) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendedHotelsPage(
          hotels: recommendedHotels,
          checkInDate: _selectedDateRange?.start,
          checkOutDate: _selectedDateRange?.end,
          guests: _selectedGuests,
          title: 'Recommended Hotels',
        ),
      ),
    );
  }

  void _navigateToExplorePlacePage(List<Hotel> hotelsList, String placeName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExplorePlacesHotelListPage(
          hotels: hotelsList,
          placeName: placeName,
        ),
      ),
    );
  }

  final TextEditingController _locationController = TextEditingController(
    text: 'Yogyakarta',
  );
  DateTimeRange? _selectedDateRange;
  int _selectedGuests = 2;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(
      start: DateTime(2026, 3, 10),
      end: DateTime(2026, 3, 16),
    );
    _fetchDeviceLocation();
  }

  Future<void> _fetchDeviceLocation() async {
    try {
      final ipResponse = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 3));
      if (ipResponse.statusCode == 200) {
        final data = jsonDecode(ipResponse.body);
        if (data['city'] != null) {
          if (mounted) {
            setState(() {
              _deviceLocation =
                  "${data['city']}, ${data['country_code'] ?? 'ID'}";
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching device location: $e");
    }
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return 'Select Dates';
    final start = range.start;
    final end = range.end;

    String getMonthName(int m) {
      const List<String> names = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return names[m - 1];
    }

    return "${getMonthName(start.month)} ${start.day} ${start.year} - ${getMonthName(end.month)} ${end.day} ${end.year}";
  }

  Future<void> _toggleBookmark(Hotel hotel, int idUser) async {
    final success = await ref
        .read(savedHotelsProvider.notifier)
        .toggleSave(hotel, idUser);
    if (success) {
      final isSavedNow = ref
          .read(savedHotelsProvider)
          .relationMap
          .containsKey(hotel.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSavedNow
                ? '${hotel.nama} bookmarked successfully!'
                : '${hotel.nama} removed from bookmarks',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  List<Hotel> _getCategoryHotels(List<Hotel> source) {
    switch (_selectedCategoryIndex) {
      case 0: // Near me (mock: take hotels with ratings <= 4.6 or deterministic)
        return source.where((h) => h.rating <= 4.6).toList();
      case 1: // Popular
        return source.where((h) => h.rating >= 4.7).toList();
      case 2: // Top rates
        return source.where((h) => h.rating >= 4.8).toList();
      case 3: // Trending
        return source.take(4).toList();
      default:
        return source;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = widget.token == null || widget.token!.isEmpty;

    // Watch Riverpod states
    final hotelsAsync = ref.watch(hotelsProvider);
    final savedState = ref.watch(savedHotelsProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: hotelsAsync.when(
        loading: () => const LoadingAnimation(),
        error: (err, stack) =>
            Center(child: Text('Error loading hotels: $err')),
        data: (hotelsList) {
          // Stable filtering without random shuffles to avoid jumping UI
          final recommendedHotels = hotelsList.take(5).toList();
          final categoryHotels = _getCategoryHotels(hotelsList);

          // Get logged in user details
          final profile = profileAsync.valueOrNull;
          final userName = profile?['nama'] ?? '';
          final idUser = profile?['id_user'] ?? 1;

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                ref.refresh(hotelsProvider.future),
                ref.read(savedHotelsProvider.notifier).loadSavedHotels(),
                ref.refresh(profileProvider.future),
              ]);
            },
            color: AppTheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
              SliverToBoxAdapter(
                child: isGuest
                    ? _buildIntroHeroHeader()
                    : _buildUserHeroHeader(userName),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader(
                      'Recommended Hotels',
                      isGuest,
                      onViewAllTap: () =>
                          _navigateToRecommendedPage(recommendedHotels),
                    ),
                    const SizedBox(height: 12),
                    recommendedHotels.isEmpty
                        ? _buildEmptyIndicator('No recommended stays available')
                        : SizedBox(
                            height: 195,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: recommendedHotels.length,
                              physics: const BouncingScrollPhysics(),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final hotel = recommendedHotels[index];
                                final isBookmarked =
                                    !isGuest &&
                                    savedState.relationMap.containsKey(
                                      hotel.id,
                                    );
                                return HotelCard(
                                  hotel: hotel,
                                  isBookmarked: isBookmarked,
                                  onTap: isGuest
                                      ? widget.onActionRestricted
                                      : () => _navigateToHotelPage(hotel),
                                  onBookmarkTap: isGuest
                                      ? widget.onActionRestricted
                                      : () => _toggleBookmark(hotel, idUser),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Explore Place',
                      isGuest,
                      onViewAllTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAllExplorePlacePage(
                              hotels: hotelsList,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 95,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _places.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return PlaceCard(
                            place: _places[index],
                            onTap: isGuest
                                ? widget.onActionRestricted
                                : () => _navigateToExplorePlacePage(
                                    hotelsList,
                                    _places[index].name,
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    CategoryTabs(
                      selectedIndex: _selectedCategoryIndex,
                      onChanged: (index) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    categoryHotels.isEmpty
                        ? _buildEmptyIndicator(
                            'No stays found under this category',
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categoryHotels.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final hotel = categoryHotels[index];
                              final isBookmarked =
                                  !isGuest &&
                                  savedState.relationMap.containsKey(hotel.id);
                              return HotelListCard(
                                hotel: hotel,
                                isBookmarked: isBookmarked,
                                onTap: isGuest
                                    ? widget.onActionRestricted
                                    : () => _navigateToHotelPage(hotel),
                                onBookmarkTap: isGuest
                                    ? widget.onActionRestricted
                                    : () => _toggleBookmark(hotel, idUser),
                              );
                            },
                          ),
                  ]),
                ),
              ),
            ],
          ));
        },
      ),
    );
  }

  // --- Guest View Builders ---
  Widget _buildIntroHeroHeader() {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          const Positioned.fill(
            child: SmartImage(
              path: 'assets/images/header_picture.jpg',
              fit: BoxFit.cover,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.12),
                    const Color(0xFFF6F7F9).withOpacity(0.95),
                  ],
                  stops: const [0, 0.65, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's Find\nThe Best Hotel !",
                  style: AppTheme.titleStyle.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 1.5),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildIntroSearchBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepTeal.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onLoginTap,
          child: SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Look for homestay',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.search_rounded,
                    color: AppTheme.accentTeal,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- User View Builders ---
  Widget _buildUserHeroHeader(String userName) {
    return SizedBox(
      height: 380,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: const SmartImage(
              path: 'assets/images/header_picture.jpg',
              fit: BoxFit.cover,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.12),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _deviceLocation,
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hello, $userName!',
                  style: AppTheme.titleStyle.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SearchCard(
              locationController: _locationController,
              dateRangeStr: _selectedDateRange != null
                  ? _formatDateRange(_selectedDateRange)
                  : 'March 10 2026 - March 16 2026',
              guestsStr:
                  '$_selectedGuests Guest${_selectedGuests > 1 ? 's' : ''}',
              onTapDates: _showDateRangePicker,
              onTapGuests: _showGuestsPicker,
              onSearchPressed: _onSearchPressed,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      barrierDismissible: true,
      builder: (_) => DateRangePopup(
        initialRange:
            _selectedDateRange ??
            DateTimeRange(
              start: today.add(const Duration(days: 1)),
              end: today.add(const Duration(days: 7)),
            ),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _showGuestsPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Number of Guests',
                style: AppTheme.titleStyle.copyWith(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  final guestCount = index + 1;
                  return ListTile(
                    leading: const Icon(
                      Icons.people_outline_rounded,
                      color: AppTheme.accentTeal,
                    ),
                    title: Text(
                      '$guestCount Guest${guestCount > 1 ? 's' : ''}',
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: _selectedGuests == guestCount
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.tealDark,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedGuests = guestCount;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSearchPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          location: _locationController.text.trim(),
          checkInDate: _selectedDateRange?.start,
          checkOutDate: _selectedDateRange?.end,
          guests: _selectedGuests,
        ),
      ),
    );
  }

  void _navigateToHotelPage(Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HotelDetailPage(hotel: hotel)),
    );
  }

  // --- Shared View Builders ---
  Widget _buildSectionHeader(
    String title,
    bool isGuest, {
    required VoidCallback onViewAllTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.subtitleStyle.copyWith(
            color: AppTheme.deepTeal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        GestureDetector(
          onTap: isGuest ? widget.onLoginTap : onViewAllTap,
          child: Text(
            'View All',
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.accentTeal,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyIndicator(String text) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
