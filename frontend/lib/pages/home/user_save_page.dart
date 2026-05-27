import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/models/hotel_model.dart';
import 'package:sona/services/api_service.dart';
import 'package:sona/widgets/saved/saved_hotel_card.dart';
import 'package:sona/pages/hotels/hotel_page.dart';

class UserSavePage extends StatefulWidget {
  final VoidCallback onExploreTap;

  const UserSavePage({
    super.key,
    required this.onExploreTap,
  });

  @override
  State<UserSavePage> createState() => _UserSavePageState();
}

class _UserSavePageState extends State<UserSavePage> {
  bool _isLoading = true;
  int? _userId;
  String? _token;
  int _selectedTab = 0; // 0 = All, 1 = Popular, 2 = Near me
  List<HotelModel> _savedHotels = [];
  Map<int, int> _savedHotelRelations = {}; // hotel_id -> id_savehotel

  @override
  void initState() {
    super.initState();
    _loadSavedHotels();
  }

  Future<void> _loadSavedHotels() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    int userId = 1; // Default fallback user ID
    
    if (mounted) {
      setState(() {
        _token = token;
        _isLoading = true;
      });
    }

    if (token != null) {
      // 1. Fetch user ID dynamically from /me endpoint
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
          if (userData != null && userData['id_user'] != null) {
            userId = userData['id_user'];
          }
        }
      } catch (e) {
        debugPrint("Error fetching logged in profile in saved page: $e");
      }

      if (mounted) {
        setState(() {
          _userId = userId;
        });
      }

      final apiService = ApiService();
      final result = await apiService.fetchSavedHotels(userId, token);
      
      if (mounted) {
        setState(() {
          _savedHotels = List<HotelModel>.from(result['hotels'] ?? []);
          _savedHotelRelations = Map<int, int>.from(result['relations'] ?? {});
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeBookmark(HotelModel hotel) async {
    if (_token == null || _userId == null) return;
    
    final apiService = ApiService();
    final saveId = _savedHotelRelations[hotel.id];
    
    if (saveId != null) {
      final success = await apiService.toggleSaveHotel(saveId, _token!);
      if (success) {
        if (mounted) {
          setState(() {
            _savedHotels.removeWhere((item) => item.id == hotel.id);
            _savedHotelRelations.remove(hotel.id);
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${hotel.nama} removed from saved list')),
          );
        }
      }
    }
  }

  double _getDistanceForHotel(HotelModel hotel) {
    // Generates a realistic distance (e.g. 2.5 km) based on ID matching SavedHotelCard
    return 1.5 + (hotel.id * 0.7) % 3.0;
  }

  List<HotelModel> get _filteredHotels {
    if (_selectedTab == 1) {
      // Filter for rating > 4.0 for Popular tab, sorted by rating descending
      final list = _savedHotels.where((hotel) => hotel.rating > 4.0).toList();
      list.sort((a, b) => b.rating.compareTo(a.rating));
      return list;
    } else if (_selectedTab == 2) {
      // Filter for distance <= 5.0 km for Near me tab
      return _savedHotels.where((hotel) => _getDistanceForHotel(hotel) <= 5.0).toList();
    }
    return _savedHotels;
  }

  Widget _buildTabItem(int index, String label) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.deepTeal : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.deepTeal : AppTheme.textGrey,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
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
          'Saved Hotels',
          style: TextStyle(
            color: AppTheme.deepTeal,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    _buildTabItem(0, 'All'),
                    const SizedBox(width: 24),
                    _buildTabItem(1, 'Popular'),
                    const SizedBox(width: 24),
                    _buildTabItem(2, 'Near me'),
                  ],
                ),
                Container(
                  height: 1,
                  color: AppTheme.borderGrey,
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
          : _savedHotels.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSavedHotels,
                  color: AppTheme.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                    itemCount: _filteredHotels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final hotel = _filteredHotels[index];
                      return SavedHotelCard(
                        hotel: hotel,
                        showDistance: _selectedTab == 2,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HotelPage(
                                location: hotel.alamat,
                              ),
                            ),
                          );
                        },
                        onBookmarkTap: () => _removeBookmark(hotel),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/save_image.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'No Saved Hotels Yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.deepTeal,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Hotels you bookmark will appear here. \nStart exploring and save your favorite stays',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 170,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.softTealGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.deepTeal.withOpacity(0.24),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: widget.onExploreTap,
                  icon: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: const Text(
                    'Explore Hotel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
