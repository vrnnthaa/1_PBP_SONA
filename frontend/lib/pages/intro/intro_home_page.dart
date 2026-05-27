import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/models/hotel_model.dart';
import 'package:sona/models/intro_models.dart';
import 'package:sona/services/api_service.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/widgets/home/hotel_card.dart';
import 'package:sona/widgets/home/place_card.dart';
import 'package:sona/widgets/home/hotel_list_card.dart';
import 'package:sona/widgets/home/category_tabs.dart';

class IntroHomePage extends StatefulWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onActionRestricted;

  const IntroHomePage({
    super.key,
    required this.onLoginTap,
    required this.onActionRestricted,
  });

  @override
  State<IntroHomePage> createState() => _IntroHomePageState();
}

class _IntroHomePageState extends State<IntroHomePage> {
  int _selectedCategoryIndex = 0;
  bool _isLoading = true;

  // Cached random lists for horizontal recommended list and category tabs
  List<HotelModel> _recommendedHotels = [];
  List<HotelModel> _nearestHotels = [];
  List<HotelModel> _popularHotels = [];
  List<HotelModel> _topRatesHotels = [];
  List<HotelModel> _trendingHotels = [];

  // Local destinations mockup for beautiful UI
  final List<PlaceData> _places = const [
    PlaceData(name: 'Bali', imagePath: 'assets/images/place_bali.jpg'),
    PlaceData(name: 'Labuan Bajo', imagePath: 'assets/images/place_labuan_bajo.jpg'),
    PlaceData(name: 'Lombok', imagePath: 'assets/images/place_lombok.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    final apiService = ApiService();
    final hotels = await apiService.fetchHotels();
    if (mounted) {
      setState(() {

        // Helper to select up to 5 random hotels
        List<HotelModel> getRandomHotels(List<HotelModel> source, int count) {
          if (source.isEmpty) return [];
          final list = List<HotelModel>.from(source)..shuffle();
          return list.take(count).toList();
        }

        _recommendedHotels = getRandomHotels(hotels, 5);
        _nearestHotels = getRandomHotels(hotels, 5);
        _popularHotels = getRandomHotels(hotels, 5);
        _topRatesHotels = getRandomHotels(hotels, 5);
        _trendingHotels = getRandomHotels(hotels, 5);

        _isLoading = false;
      });
    }
  }

  // Helper method to split retrieved database hotels by index categories dynamically
  List<HotelModel> _getCategoryHotels() {
    switch (_selectedCategoryIndex) {
      case 0:
        return _nearestHotels;
      case 1:
        return _popularHotels;
      case 2:
        return _topRatesHotels;
      case 3:
        return _trendingHotels;
      default:
        return _nearestHotels;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show circular loader spinner during data fetch from backend
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      );
    }

    final categoryHotels = _getCategoryHotels();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeroHeader(),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildSectionHeader('Recommended Hotels', widget.onLoginTap),
                  const SizedBox(height: 12),
                  _recommendedHotels.isEmpty
                      ? _buildEmptyIndicator('No recommended stays available')
                      : SizedBox(
                          height: 195,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _recommendedHotels.length,
                            physics: const BouncingScrollPhysics(),
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              return HotelCard(
                                hotel: _recommendedHotels[index],
                                onTap: widget.onActionRestricted,
                                onBookmarkTap: widget.onActionRestricted,
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Explore Place', widget.onLoginTap),
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
                          onTap: widget.onActionRestricted,
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
                      ? _buildEmptyIndicator('No stays found under this category')
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryHotels.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return HotelListCard(
                              hotel: categoryHotels[index],
                              onTap: widget.onActionRestricted,
                              onBookmarkTap: widget.onActionRestricted,
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          const Positioned.fill(
            child: SmartImage(
              path: 'assets/images/home_hero.jpg',
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
                const Text(
                  "Let's Find\nThe Best Hotel !",
                  style: TextStyle(
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
                _buildSearchBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
          child: const SizedBox(
            height: 50,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Look for homestay',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
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

  Widget _buildSectionHeader(String title, VoidCallback onViewAllTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.deepTeal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        GestureDetector(
          onTap: onViewAllTap,
          child: const Text(
            'View All',
            style: TextStyle(
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
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
