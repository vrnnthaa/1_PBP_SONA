import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/models/hotel_model.dart';
import 'package:sona/models/intro_models.dart';
import 'package:sona/services/api_service.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/widgets/home/hotel_card.dart';
import 'package:sona/widgets/home/place_card.dart';
import 'package:sona/widgets/home/hotel_list_card.dart';
import 'package:sona/widgets/home/category_tabs.dart';
import 'package:sona/widgets/home/search_card.dart';
import 'package:sona/pages/hotels/hotel_page.dart';

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
  String _userName = 'Olivia'; // Dynamic greeting name
  String _deviceLocation = 'Yogyakarta, Indonesia'; // Dynamic device location

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

  // Interactive fields matching mockups
  final TextEditingController _locationController = TextEditingController(text: 'Yogyakarta');
  DateTimeRange? _selectedDateRange;
  int _selectedGuests = 2;

  @override
  void initState() {
    super.initState();
    // Default selected date range to mock March 10 2026 - March 16 2026
    _selectedDateRange = DateTimeRange(
      start: DateTime(2026, 3, 10),
      end: DateTime(2026, 3, 16),
    );
    _loadData();
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return 'Select Dates';
    final start = range.start;
    final end = range.end;
    
    // Correct index lookup safely
    String getMonthName(int m) {
      const List<String> names = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return names[m - 1];
    }
    
    return "${getMonthName(start.month)} ${start.day} ${start.year} - ${getMonthName(end.month)} ${end.day} ${end.year}";
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final apiService = ApiService();
    int userId = 1; // Default fallback user ID
    
    setState(() {
      _token = token;
      _userId = userId;
    });

    // 1. Fetch real hotel data from the database
    List<HotelModel> hotels = [];
    try {
      hotels = await apiService.fetchHotels();
    } catch (e) {
      debugPrint("Error fetching hotels: $e");
    }
    
    // 2. Fetch saved hotels relations
    Map<String, dynamic> savedResult = {};
    if (token != null) {
      try {
        savedResult = await apiService.fetchSavedHotels(userId, token);
      } catch (e) {
        debugPrint("Error fetching saved hotels: $e");
      }
    }

    // 3. Fetch logged-in user profile details dynamically
    if (token != null) {
      try {
        final profileResponse = await http.get(
          Uri.parse('${ApiService.baseUrl}/me'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        if (profileResponse.statusCode == 200) {
          final result = jsonDecode(profileResponse.body);
          final userData = result['data'];
          if (userData != null && userData['nama'] != null) {
            setState(() {
              _userName = userData['nama'];
              if (userData['id_user'] != null) {
                _userId = userData['id_user'];
              }
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching logged in profile: $e");
      }
    }

    // 4. Fetch dynamic device location based on IP address
    try {
      final ipResponse = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 3));
      if (ipResponse.statusCode == 200) {
        final data = jsonDecode(ipResponse.body);
        if (data['city'] != null) {
          setState(() {
            _deviceLocation = "${data['city']}, ${data['country_code'] ?? 'ID'}";
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching device location: $e");
    }

    if (mounted) {
      setState(() {
        _allHotels = hotels;
        _savedHotelRelations = Map<int, int>.from(savedResult['relations'] ?? {});

        // Fallback to real database hotels if the API load failed or is empty
        final displayHotels = hotels.isNotEmpty ? hotels : ApiService.fallbackHotels;

        List<HotelModel> getRandomHotels(List<HotelModel> source, int count) {
          if (source.isEmpty) return [];
          final list = List<HotelModel>.from(source)..shuffle();
          return list.take(count).toList();
        }

        // Display raw DB hotels directly as requested!
        _recommendedHotels = getRandomHotels(displayHotels, 5);
        _nearestHotels = getRandomHotels(displayHotels, 5);
        _popularHotels = getRandomHotels(displayHotels, 5);
        _topRatesHotels = getRandomHotels(displayHotels, 5);
        _trendingHotels = getRandomHotels(displayHotels, 5);

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
        if (mounted) {
          setState(() {
            _savedHotelRelations.remove(hotel.id);
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${hotel.nama} removed from bookmarks')),
          );
        }
      }
    } else {
      // Create new bookmark relation
      final success = await apiService.saveHotel(_userId!, hotel.id, _token!);
      if (success) {
        // Refresh save map to get the new id_savehotel
        final savedResult = await apiService.fetchSavedHotels(_userId!, _token!);
        if (mounted) {
          setState(() {
            _savedHotelRelations = Map<int, int>.from(savedResult['relations'] ?? {});
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${hotel.nama} bookmarked successfully!')),
          );
        }
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
                                onTap: () => _navigateToHotelPage(hotel),
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
                              onTap: () => _navigateToHotelPage(hotel),
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
      height: 380, // Taller to fit background and overlapping card
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background resort palms image (height: 240)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: const SmartImage(
              path: 'assets/images/home_hero.jpg',
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
          // Current Location Badge and greeting "Hello, [User]!"
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.white, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        _deviceLocation,
                        style: const TextStyle(
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
                  'Hello, $_userName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Overlapping card positioned at the bottom of our 380px header box
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SearchCard(
              locationController: _locationController,
              dateRangeStr: _selectedDateRange != null 
                  ? _formatDateRange(_selectedDateRange)
                  : 'March 10 2026 - March 16 2026',
              guestsStr: '$_selectedGuests Guest${_selectedGuests > 1 ? 's' : ''}',
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
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: DateTime(2026, 3, 10),
        end: DateTime(2026, 3, 16),
      ),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.tealDark,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.tealDark,
              ),
            ),
          ),
          child: child!,
        );
      },
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
              const Text(
                'Select Number of Guests',
                style: TextStyle(
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
                    leading: const Icon(Icons.people_outline_rounded, color: AppTheme.accentTeal),
                    title: Text(
                      '$guestCount Guest${guestCount > 1 ? 's' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: _selectedGuests == guestCount
                        ? const Icon(Icons.check_circle_rounded, color: AppTheme.tealDark)
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
        builder: (context) => HotelPage(
          location: _locationController.text,
          dateRange: _formatDateRange(_selectedDateRange),
          guests: '$_selectedGuests Guest${_selectedGuests > 1 ? 's' : ''}',
        ),
      ),
    );
  }

  void _navigateToHotelPage(HotelModel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelPage(
          location: hotel.alamat,
          dateRange: _formatDateRange(_selectedDateRange),
          guests: '$_selectedGuests Guest${_selectedGuests > 1 ? 's' : ''}',
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
