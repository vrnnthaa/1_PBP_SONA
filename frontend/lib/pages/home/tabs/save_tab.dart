import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/widgets/saved/saved_hotel_card.dart';
import 'package:sona/pages/hotels/hotel_page.dart';
import 'package:sona/providers/app_providers.dart';

class SaveTab extends ConsumerStatefulWidget {
  final String? token;
  final VoidCallback onExploreTap;

  const SaveTab({
    super.key,
    required this.token,
    required this.onExploreTap,
  });

  @override
  ConsumerState<SaveTab> createState() => _SaveTabState();
}

class _SaveTabState extends ConsumerState<SaveTab> {
  int _selectedTab = 0; // 0 = All, 1 = Popular, 2 = Near me

  double _getDistanceForHotel(Hotel hotel) {
    // Generates a realistic distance (e.g. 2.5 km) based on ID matching SavedHotelCard
    return 1.5 + (hotel.id * 0.7) % 3.0;
  }

  List<Hotel> _getFilteredHotels(List<Hotel> savedHotels) {
    if (_selectedTab == 1) {
      // Filter for rating > 4.0 for Popular tab, sorted by rating descending
      final list = savedHotels.where((hotel) => hotel.rating > 4.0).toList();
      list.sort((a, b) => b.rating.compareTo(a.rating));
      return list;
    } else if (_selectedTab == 2) {
      // Filter for distance <= 5.0 km for Near me tab
      return savedHotels.where((hotel) => _getDistanceForHotel(hotel) <= 5.0).toList();
    }
    return savedHotels;
  }

  Future<void> _removeBookmark(Hotel hotel, int idUser) async {
    final success = await ref.read(savedHotelsProvider.notifier).toggleSave(hotel, idUser);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${hotel.nama} removed from saved list'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
          style: AppTheme.bodyStyle.copyWith(
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
    final isGuest = widget.token == null || widget.token!.isEmpty;

    // Watch savedHotelsProvider and profileProvider
    final savedState = ref.watch(savedHotelsProvider);
    final profileAsync = ref.watch(profileProvider);
    
    final idUser = profileAsync.valueOrNull?['id_user'] ?? 1;

    if (savedState.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      );
    }

    if (isGuest || savedState.hotels.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Saved Hotels',
            style: AppTheme.titleStyle.copyWith(
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
        body: _buildEmptyState(),
      );
    }

    final filteredHotels = _getFilteredHotels(savedState.hotels);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Saved Hotels',
          style: AppTheme.titleStyle.copyWith(
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(savedHotelsProvider.notifier).loadSavedHotels(),
        color: AppTheme.primary,
        child: filteredHotels.isEmpty
            ? Center(
                child: Text(
                  'No stays match this filter',
                  style: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey, fontSize: 14),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                itemCount: filteredHotels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final hotel = filteredHotels[index];
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
                    onBookmarkTap: () => _removeBookmark(hotel, idUser),
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
              Text(
                'No Saved Hotels Yet',
                textAlign: TextAlign.center,
                style: AppTheme.titleStyle.copyWith(
                  color: AppTheme.deepTeal,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hotels you bookmark will appear here. \nStart exploring and save your favorite stays',
                textAlign: TextAlign.center,
                style: AppTheme.bodyStyle.copyWith(
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
                  label: Text(
                    'Explore Hotel',
                    style: AppTheme.bodyStyle.copyWith(
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
