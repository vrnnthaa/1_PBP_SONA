import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/services/api_service.dart';

class UserHistoryPage extends StatefulWidget {
  final VoidCallback onExploreTap;

  const UserHistoryPage({
    super.key,
    required this.onExploreTap,
  });

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  bool _isLoading = true;
  int? _userId;
  String? _token;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    int userId = 1; // Default fallback user ID
    
    setState(() {
      _token = token;
      _userId = userId;
    });

    if (token != null) {
      final apiService = ApiService();
      final list = await apiService.fetchUserBookings(userId, token);
      if (mounted) {
        setState(() {
          _bookings = list;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'History',
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
          : _bookings.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                  itemCount: _bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return _buildBookingCard(booking);
                  },
                ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final String checkInStr = booking['check_in'] != null 
        ? booking['check_in'].toString().split('T')[0] 
        : '-';
    final String checkOutStr = booking['check_out'] != null 
        ? booking['check_out'].toString().split('T')[0] 
        : '-';
    
    final int visitors = booking['jumlah_pengunjung'] ?? 1;
    final double cost = double.tryParse(booking['total_biaya'].toString()) ?? 0.0;
    final String status = booking['status_pemesanan'] ?? 'pending';

    Color badgeColor = Colors.orange;
    if (status == 'confirmed') {
      badgeColor = Colors.green;
    } else if (status == 'canceled') {
      badgeColor = AppTheme.errorRed;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderGrey, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking #${booking['id_pemesanan']}',
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.borderGrey, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.date_range_rounded, color: AppTheme.textGrey, size: 16),
              const SizedBox(width: 6),
              Text(
                '$checkInStr  to  $checkOutStr',
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: AppTheme.textGrey, size: 16),
              const SizedBox(width: 6),
              Text(
                '$visitors Visitor(s)',
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Cost',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rp ${cost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: const TextStyle(
                  color: AppTheme.deepTeal,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
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
              'No Booking History Yet',
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
              'Your past bookings will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: AppTheme.deepTeal,
                    shape: BoxShape.circle,
                  ),
                ),
                const Text(
                  'Start exploring and book your first stay',
                  style: TextStyle(
                    color: AppTheme.deepTeal,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
              left: index == 0 ? 24 : null,
              right: index == 1 ? 12 : null,
              top: index == 2 ? 24 : null,
              bottom: index == 0 ? 18 : null,
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
            right: 16,
            top: 18,
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
                        Icons.search_rounded,
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
