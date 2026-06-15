import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/widgets/loading_animation.dart';
import 'package:intl/intl.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/entity/hotel/hotel.dart';

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
    final double cost = double.tryParse(booking['total_biaya'].toString()) ?? 0.0;
    final String status = (booking['status_pemesanan'] ?? 'pending').toString().toLowerCase();
    final hotelJson = booking['kamar']?['hotel'];
    final Hotel? hotel = hotelJson != null ? Hotel.fromJson(hotelJson) : null;
    final String namaHotel = hotel?.nama ?? 'Unknown Hotel';
    
    final String imageUrl = hotel?.imagePath ?? 'images/hotel_paradise_resort.jpg';

    final DateTime checkInDate = DateTime.tryParse(booking['check_in'] ?? '') ?? DateTime.now();
    final DateTime checkOutDate = DateTime.tryParse(booking['check_out'] ?? '') ?? DateTime.now();

    final String formattedCheckIn = DateFormat('MMM dd', 'en_US').format(checkInDate);
    final String formattedCheckOut = DateFormat('MMM dd', 'en_US').format(checkOutDate);

    final int days = checkOutDate.difference(checkInDate).inDays;
    final String dateRange = '$formattedCheckIn - $formattedCheckOut, ${checkOutDate.year} • $days ${days > 1 ? 'Days' : 'day'}';

    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp. ', 
      decimalDigits: 0
    );

    final String formattedCost = currencyFormat.format(cost);

    // Mapping menggunakan AppTheme
    Color statusColor = const Color(0xFF00BD25); // Warna sukses dari Figma
    String statusText = "Completed";
    
    if (status == 'canceled') {
      statusColor = AppTheme.errorRed; 
      statusText = "Cancel";
    } else if (status == 'menunggu_review') {
      statusColor = AppTheme.starYellow;
      statusText = "Wait Review";
    } else if (status == 'aktif') {
      statusColor = AppTheme.tealLight;
      statusText = "Active";
    }

    return Container(
      width: 330,
      padding: const EdgeInsets.all(15),
      decoration: ShapeDecoration(
        color: AppTheme.background, // Menggunakan warna background dari AppTheme
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.20, color: Colors.black.withOpacity(0.20)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 2, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statusText, 
                        style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(namaHotel, 
                        style: AppTheme.titleStyle.copyWith(fontSize: 16, color: AppTheme.primary)),
                      Text(dateRange, 
                        style: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey, fontSize: 12)),
                      const SizedBox(height: 3),
                      Text(formattedCost, 
                        style: AppTheme.titleStyle.copyWith(fontSize: 16, color: AppTheme.primary)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 68,
                  height: 68,
                  child: SmartImage(
                    path: imageUrl,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),              
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: AppTheme.borderLight),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 33,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Write a Review', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 11),
              Container(
                width: 33, height: 33,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  border: Border.all(width: 0.6, color: AppTheme.borderTealLight),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.receipt_long, size: 18, color: AppTheme.primary),
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
