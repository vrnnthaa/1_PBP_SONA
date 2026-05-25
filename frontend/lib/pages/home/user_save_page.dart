import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/models/hotel_model.dart';
import 'package:sona/services/api_service.dart';
import 'package:sona/widgets/intro/hotel_list_card.dart';

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
    
    setState(() {
      _token = token;
      _userId = userId;
    });

    if (token != null) {
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
        setState(() {
          _savedHotels.removeWhere((item) => item.id == hotel.id);
          _savedHotelRelations.remove(hotel.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${hotel.nama} removed from saved list')),
        );
      }
    }
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
            fontSize: 18,
            fontWeight: FontWeight.w800,
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
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
          : _savedHotels.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                  itemCount: _savedHotels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final hotel = _savedHotels[index];
                    return HotelListCard(
                      hotel: hotel,
                      isBookmarked: true,
                      onTap: () {},
                      onBookmarkTap: () => _removeBookmark(hotel),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            _buildOwlIllustration(context),
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
              'Hotels you bookmark will appear here. Start exploring and save your favorite stays',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 170,
              height: 44,
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
                  backgroundColor: AppTheme.deepTeal,
                  elevation: 3,
                  shadowColor: AppTheme.deepTeal.withOpacity(0.24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildOwlIllustration(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppTheme.softCyan.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(3, (index) {
            return Positioned(
              right: index == 0 ? 18 : null,
              left: index == 1 ? 12 : null,
              top: index == 2 ? 18 : null,
              bottom: index == 0 ? 24 : null,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          Positioned(
            right: 20,
            top: 28,
            child: Icon(
              Icons.insights_rounded,
              color: AppTheme.accentTeal.withOpacity(0.26),
              size: 40,
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentTeal.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 22,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOwlEye(),
                      const SizedBox(width: 8),
                      _buildOwlEye(),
                    ],
                  ),
                ),
                Positioned(
                  top: 38,
                  child: Container(
                    width: 8,
                    height: 11,
                    decoration: BoxDecoration(
                      color: AppTheme.starYellow,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  child: Container(
                    width: 26,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.softCyan,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.bookmark_rounded,
                        color: AppTheme.accentTeal,
                        size: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwlEye() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppTheme.softCyan,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.accentTeal, width: 1.2),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.deepTeal,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
