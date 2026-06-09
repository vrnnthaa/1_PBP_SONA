import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/widgets/loading_animation.dart';

class HistoryTab extends ConsumerWidget {
  final String? token;
  final VoidCallback onExploreTap;

  const HistoryTab({
    super.key,
    required this.token,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = token == null || token!.isEmpty;

    // Watch bookingsProvider
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'History',
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
      body: isGuest
          ? _buildGuestEmptyState()
          : bookingsAsync.when(
              loading: () => const LoadingAnimation(),
              error: (err, stack) => Center(
                child: Text('Error loading booking history: $err'),
              ),
              data: (bookings) {
                return bookings.isEmpty
                    ? _buildUserEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: () => ref.refresh(bookingsProvider.future),
                        color: AppTheme.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                          itemCount: bookings.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return _buildBookingCard(booking);
                          },
                        ),
                      );
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
                style: AppTheme.titleStyle.copyWith(
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
                  style: AppTheme.bodyStyle.copyWith(
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
                style: AppTheme.bodyStyle.copyWith(
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
                style: AppTheme.bodyStyle.copyWith(
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
              Text(
                'Total Cost',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rp ${cost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: AppTheme.titleStyle.copyWith(
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

  Widget _buildGuestEmptyState() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Image.asset(
              'assets/images/history_image.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'No Booking History Yet',
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
              'Your past bookings will appear here',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle.copyWith(
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
                onPressed: onExploreTap,
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
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildUserEmptyState(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Image.asset(
              'assets/images/history_image.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'No Booking History Yet',
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
              'Your past bookings will appear here',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle.copyWith(
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
                onPressed: onExploreTap,
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
}
