import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/models/hotel_model.dart';
import 'package:sona/models/intro_models.dart';
import 'package:sona/services/api_service.dart';
import 'package:sona/widgets/intro/smart_image.dart';
import 'package:sona/widgets/intro/hotel_card.dart';
import 'package:sona/widgets/intro/place_card.dart';
import 'package:sona/widgets/intro/hotel_list_card.dart';
import 'package:sona/widgets/intro/category_tabs.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedCategoryIndex = 0;
  bool _isLoading = true;
  int? _userId;
  String? _token;

  List<HotelModel> _allHotels = [];
  List<HotelModel> _recommendedHotels = [];
  List<HotelModel> _nearestHotels = [];
  List<HotelModel> _popularHotels = [];
  List<HotelModel> _topRatesHotels = [];
  List<HotelModel> _trendingHotels = [];
  
  // Keep track of which hotel_id is saved to its relation id_savehotel
  Map<int, int> _savedHotelRelations = {};

  final List<PlaceData> _places = const [
    PlaceData(name: 'Bali', imagePath: 'assets/images/place_bali.jpg'),
    PlaceData(name: 'Labuan Bajo', imagePath: 'assets/images/place_labuan_bajo.jpg'),
    PlaceData(name: 'Lombok', imagePath: 'assets/images/place_lombok.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    // Parse user ID from the saved credentials or make a quick profile call
    final apiService = ApiService();
    
    // For demo/prototype robustness, let's look up /me or user state
    int userId = 1; // Default fallback user ID
    
    setState(() {
      _token = token;
      _userId = userId;
    });

    final hotels = await apiService.fetchHotels();
    
    // Fetch saved/bookmarked hotels from database
    Map<String, dynamic> savedResult = {};
    if (token != null) {
      savedResult = await apiService.fetchSavedHotels(userId, token);
    }

    if (mounted) {
      setState(() {
        _allHotels = hotels;
        _savedHotelRelations = Map<int, int>.from(savedResult['relations'] ?? {});

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

  Future<void> _toggleBookmark(HotelModel hotel) async {
    if (_token == null || _userId == null) return;
    
    final apiService = ApiService();
    final isBookmarked = _savedHotelRelations.containsKey(hotel.id);
    
    if (isBookmarked) {
      // Toggle off / Unbookmark using relationship id
      final saveId = _savedHotelRelations[hotel.id]!;
      final success = await apiService.toggleSaveHotel(saveId, _token!);
      if (success) {
        setState(() {
          _savedHotelRelations.remove(hotel.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${hotel.nama} removed from bookmarks')),
        );
      }
    } else {
      // Create new bookmark relation
      final success = await apiService.saveHotel(_userId!, hotel.id, _token!);
      if (success) {
        // Refresh save map to get the new id_savehotel
        final savedResult = await apiService.fetchSavedHotels(_userId!, _token!);
        setState(() {
          _savedHotelRelations = Map<int, int>.from(savedResult['relations'] ?? {});
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${hotel.nama} bookmarked successfully!')),
        );
      }
    }
  }

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
                  _buildSectionHeader('Recommended Hotels'),
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
                              final hotel = _recommendedHotels[index];
                              return HotelCard(
                                hotel: hotel,
                                isBookmarked: _savedHotelRelations.containsKey(hotel.id),
                                onTap: () => _showSuccessBookingDialog(hotel),
                                onBookmarkTap: () => _toggleBookmark(hotel),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Explore Place'),
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
                          onTap: () {},
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
                            final hotel = categoryHotels[index];
                            return HotelListCard(
                              hotel: hotel,
                              isBookmarked: _savedHotelRelations.containsKey(hotel.id),
                              onTap: () => _showSuccessBookingDialog(hotel),
                              onBookmarkTap: () => _toggleBookmark(hotel),
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
                    AppTheme.background.withOpacity(0.95),
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
      child: TextField(
        readOnly: true,
        onTap: () {},
        decoration: InputDecoration(
          hintText: 'Look for homestay',
          hintStyle: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.accentTeal,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
        const Text(
          'View All',
          style: TextStyle(
            color: AppTheme.accentTeal,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
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

  void _showSuccessBookingDialog(HotelModel hotel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Book ${hotel.nama}',
          style: const TextStyle(color: AppTheme.deepTeal, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Would you like to book a stay at ${hotel.nama} located at ${hotel.alamat}?',
          style: const TextStyle(color: AppTheme.textDark, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stay successfully reserved at ${hotel.nama}!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm Stay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
