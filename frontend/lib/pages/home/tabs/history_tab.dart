import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/providers/auth/profile_provider.dart';

// Widgets
import 'package:sona/widgets/loading_animation.dart';
import 'package:sona/widgets/home/smart_image.dart';

// Pages
import 'package:sona/pages/review/make_review_page.dart';
import 'package:sona/api/pemesanan/api_pemesanan.dart';

class HistoryTab extends ConsumerWidget {
  final String? token;
  final VoidCallback onExploreTap;

  const HistoryTab({
    super.key,
    required this.token,
    required this.onExploreTap,
  });

  // --- KATEGORI TAB (HANYA 3: ALL, COMPLETED, CANCEL) ---
  String _getBookingCategory(Map<String, dynamic> booking) {
    final statusPemesanan = (booking['status_pemesanan'] ?? 'pending').toString().toLowerCase();
    
    final dynamic paymentData = booking['pembayaran'];
    final Map<String, dynamic>? pembayaran = paymentData is List
        ? (paymentData.isNotEmpty ? paymentData.first : null)
        : (paymentData as Map<String, dynamic>?);
    final statusPembayaran = pembayaran != null ? pembayaran['status_pembayaran']?.toString().toLowerCase() : null;

    if (statusPemesanan == 'cancelled' || statusPembayaran == 'pembayaran gagal' || statusPembayaran == null || statusPembayaran == 'menunggu pembayaran') {
      return 'Canceled';
    }

    return 'Completed';
  }

  void _showBookingDetails(BuildContext context, WidgetRef ref, Map<String, dynamic> booking) {
    final profile = ref.read(profileProvider).value;
    final String userName = profile?['nama'] ?? 'Username'; 
    final String userEmail = profile?['email'] ?? 'User@gmail.com';

    final DateTime inDate = DateTime.tryParse(booking['check_in'] ?? '') ?? DateTime.now();
    final DateTime outDate = DateTime.tryParse(booking['check_out'] ?? '') ?? DateTime.now();
    final String formattedDate = '${DateFormat('dd').format(inDate)}-${DateFormat('dd MMM yyyy').format(outDate)}';
    
    final String namaHotel = booking['kamar']?['hotel']?['nama_hotel'] ?? 'Hotel';
    final String totalBiaya = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0
    ).format(double.tryParse(booking['total_biaya'].toString()) ?? 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HOTEL NAME', 
              style: AppTheme.bodyStyle.copyWith(fontSize: 10, color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
            Text(namaHotel, 
              style: AppTheme.titleStyle.copyWith(fontSize: 18, color: AppTheme.primary)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('BOOKING ID', style: AppTheme.bodyStyle.copyWith(fontSize: 10, color: AppTheme.textGrey)),
                  Text('#SONA-${booking['id_pemesanan']}', style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('NAME', style: AppTheme.bodyStyle.copyWith(fontSize: 10, color: AppTheme.textGrey)),
                  Text(userName, style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                ]),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('EMAIL', style: AppTheme.bodyStyle.copyWith(fontSize: 10, color: AppTheme.textGrey)),
                  Text(userEmail, style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('DATE', style: AppTheme.bodyStyle.copyWith(fontSize: 10, color: AppTheme.textGrey)),
                  Text(formattedDate, style: AppTheme.titleStyle.copyWith(fontSize: 14)),
                ]),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('AMOUNT PAID', style: AppTheme.bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(totalBiaya, style: AppTheme.titleStyle.copyWith(fontSize: 14, color: AppTheme.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext parentContext, WidgetRef ref, int idPemesanan, int daysToCheckIn) async {
    // 1. Validasi Lapis Pertama (Jika H-1 / H-0)
    if (daysToCheckIn < 2 && daysToCheckIn >= 0) {
      showDialog(
        context: parentContext,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Cancellation Unavailable', style: AppTheme.titleStyle.copyWith(color: AppTheme.errorRed, fontSize: 18)),
          content: Text(
            'Maaf, pesanan yang dibuat mendekati hari Check-in (H-1 / H-0) tidak dapat dibatalkan menurut kebijakan hotel.',
            style: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close', style: TextStyle(color: AppTheme.primary)),
            ),
          ],
        ),
      );
      return;
    }

    final bool isFreeCancel = daysToCheckIn >= 2;

    // 2. Tampilkan Konfirmasi dan Tunggu Jawaban User (true / false)
    final bool? shouldCancel = await showDialog<bool>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isFreeCancel ? 'Free Cancellation' : 'Late Cancellation',
          style: AppTheme.titleStyle.copyWith(color: isFreeCancel ? AppTheme.primary : AppTheme.errorRed, fontSize: 18),
        ),
        content: Text(
          isFreeCancel 
            ? 'Anda membatalkan pesanan lebih dari H-2. Anda berhak mendapatkan pengembalian dana penuh. Apakah Anda yakin ingin membatalkan pesanan ini?'
            : 'Anda membatalkan pesanan di ranah H-2 sebelum check-in. Biaya tidak akan dikembalikan sepenuhnya. Lanjutkan pembatalan?',
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey, fontSize: 14),
        ),
        actions: [
          TextButton(
            // Kembalikan nilai FALSE jika klik Keep Booking
            onPressed: () => Navigator.pop(dialogContext, false), 
            child: const Text('Keep Booking', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            // Kembalikan nilai TRUE jika klik Yes, Cancel
            onPressed: () => Navigator.pop(dialogContext, true), 
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // 3. Jika user tidak menekan 'Yes, Cancel', hentikan fungsi di sini
    if (shouldCancel != true) return;
    if (!parentContext.mounted) return;

    // 4. Jika 'Yes, Cancel' ditekan, Tampilkan Loading
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (loadingContext) => const Center(child: LoadingAnimation()),
    );

    // 5. Eksekusi API Pembatalan
    try {
      // Pastikan fungsi cancelPemesanan sudah kamu tambahkan di ApiPemesanan
      await ApiPemesanan().cancelPemesanan(idPemesanan, token ?? '');
      
      if (parentContext.mounted) {
        Navigator.pop(parentContext); // Tutup dialog loading
        ref.invalidate(bookingsProvider); // Refresh data
        
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibatalkan.')),
        );
      }
    } catch (e) {
      if (parentContext.mounted) {
        Navigator.pop(parentContext); // Tutup dialog loading
        
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text('Gagal membatalkan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = token == null || token!.isEmpty;
    final bookingsAsync = ref.watch(bookingsProvider);

    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Purchased History',
            style: AppTheme.titleStyle.copyWith(
              color: AppTheme.deepTeal,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            if (!isGuest) 
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Refresh Data',
                onPressed: () {
                  ref.invalidate(bookingsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Memperbarui riwayat pesanan...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
          ],
          bottom: const TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textGrey,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancel'),
            ],
          ),
        ),
        body: isGuest
            ? _buildGuestEmptyState()
            : bookingsAsync.when(
                loading: () => const LoadingAnimation(),
                error: (err, stack) => Center(child: Text('Error loading booking history: $err')),
                data: (bookings) {
                  return TabBarView(
                    children: [
                      _buildBookingList(context, ref, bookings, 'All'),
                      _buildBookingList(context, ref, bookings, 'Completed'),
                      _buildBookingList(context, ref, bookings, 'Canceled'),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, WidgetRef ref, List<dynamic> allBookings, String categoryFilter) {
    final filteredBookings = allBookings.where((booking) {
      if (categoryFilter == 'All') return true;
      return _getBookingCategory(booking) == categoryFilter;
    }).toList();

    // KONDISI 1: JIKA LIST KOSONG
    if (filteredBookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.refresh(bookingsProvider.future), // Aksi Swipe Down
        color: AppTheme.primary,
        child: SingleChildScrollView(
          // AlwaysScrollableScrollPhysics ini WAJIB agar layar kosong tetap bisa ditarik
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildUserEmptyState(context, categoryFilter),
          ),
        ),
      );
    }

    // KONDISI 2: JIKA LIST ADA ISINYA
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(bookingsProvider.future), // Aksi Swipe Down
      color: AppTheme.primary,
      child: ListView.separated(
        // AlwaysScrollableScrollPhysics ini WAJIB agar list bisa ditarik ke bawah
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 92), 
        itemCount: filteredBookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildBookingCard(context, ref, filteredBookings[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, WidgetRef ref, Map<String, dynamic> booking) {
    final double cost = double.tryParse(booking['total_biaya'].toString()) ?? 0.0;
    String statusPemesanan = (booking['status_pemesanan'] ?? 'pending').toString().toLowerCase();

    final dynamic paymentData = booking['pembayaran'];
    final Map<String, dynamic>? pembayaran = paymentData is List
        ? (paymentData.isNotEmpty ? paymentData.first : null)
        : (paymentData as Map<String, dynamic>?);
    
    final String? statusPembayaran = pembayaran != null ? pembayaran['status_pembayaran']?.toString().toLowerCase() : null;

    final kamarJson = booking['kamar'];
    final String namaHotel = kamarJson?['hotel']?['nama_hotel'] ?? "Unknown Hotel";
    
    String imageUrl = 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&q=80';
    if (kamarJson != null) {
      final listGambar = kamarJson['gambar_kamar'] as List;
      if (listGambar.isNotEmpty) {
        final String? urlDariDb = listGambar[0]['url_gambarkamar']?.toString();
        if (urlDariDb != null && urlDariDb.isNotEmpty) imageUrl = urlDariDb;
      }
    }

    final DateTime checkInDate = DateTime.tryParse(booking['check_in'] ?? '') ?? DateTime.now();
    final DateTime checkOutDate = DateTime.tryParse(booking['check_out'] ?? '') ?? DateTime.now();
    
    final DateTime now = DateTime.now();
    final DateTime nowDate = DateTime(now.year, now.month, now.day);
    final DateTime inDate = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    final DateTime outDate = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);

    final int daysToCheckIn = inDate.difference(nowDate).inDays;
    final int daysToCheckOut = outDate.difference(nowDate).inDays;

    final int days = checkOutDate.difference(checkInDate).inDays;
    final String formattedCheckIn = DateFormat('MMM dd', 'en_US').format(checkInDate);
    final String formattedCheckOut = DateFormat('MMM dd', 'en_US').format(checkOutDate);
    final String dateRange = '$formattedCheckIn - $formattedCheckOut, ${checkOutDate.year} • $days ${days > 1 ? 'Days' : 'day'}';

    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    final String formattedCost = currencyFormat.format(cost);

    // --- 1. FILTER UTAMA: APAKAH INI PESANAN BATAL/BELUM DIBAYAR? ---
    bool isCanceled = statusPemesanan == 'cancelled' || 
                      statusPembayaran == 'pembayaran gagal' || 
                      statusPembayaran == null || 
                      statusPembayaran == 'menunggu pembayaran';

    Color statusColor = AppTheme.primary; 
    String statusText = "Unknown";

    if (isCanceled) {
      statusColor = AppTheme.errorRed; 
      statusText = "Failed / Cancelled";
    } else {
      if (statusPemesanan == 'sudah review' || statusPemesanan == 'sudah_review') {
        statusColor = const Color(0xFF00BD25);
        statusText = "Completed";
      } else if (statusPemesanan == 'menunggu review' || statusPemesanan == 'menunggu_review' || daysToCheckOut <= 0) {
        statusColor = const Color.fromARGB(255, 105, 87, 41);
        statusText = "Wait Review";
      } else {
        statusColor = AppTheme.tealLight;
        statusText = "Active Booking";
      }
    }

    // --- 2. LOGIKA TOMBOL AKSI ---
    String buttonText = '';
    Color? buttonBgColor;
    Gradient? buttonGradient;
    Color buttonTextColor = Colors.white;
    VoidCallback? onActionTap;

    if (statusText == "Wait Review") {
      buttonText = 'Write a Review';
      buttonGradient = AppTheme.primaryGradient;
      onActionTap = () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MakeReviewPage(booking: booking)));
      };
    } else if (statusText == "Completed") {
      buttonText = 'Already Reviewed'; 
      buttonBgColor = Colors.grey.shade300;
      buttonTextColor = Colors.grey.shade600;
      onActionTap = null;
    } else if (statusText == "Active Booking") {
      // CEK H-2 ATAU H-1/H-0
      if (daysToCheckIn < 2) {
        // MATIKAN TOMBOL CANCEL JIKA SUDAH H-1 / H-0
        buttonText = 'Cannot Cancel';
        buttonBgColor = Colors.grey.shade300;
        buttonTextColor = Colors.grey.shade600;
        onActionTap = null;
      } else {
        // TOMBOL CANCEL TETAP MERAH JIKA MASIH BISA
        buttonText = 'Cancel Book';
        buttonBgColor = Colors.red.shade50;
        buttonTextColor = AppTheme.errorRed;
        onActionTap = () {
          _showCancelConfirmation(context, ref, booking['id_pemesanan'], daysToCheckIn);
        };
      }
    } else {
      buttonText = 'Unpaid / Cancelled'; 
      buttonBgColor = Colors.grey.shade300;
      buttonTextColor = Colors.grey.shade600;
      onActionTap = null;
    }

    return Container(
      width: 330,
      padding: const EdgeInsets.all(15),
      decoration: ShapeDecoration(
        color: AppTheme.background,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.20, color: Colors.black.withOpacity(0.20)),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 2, offset: Offset(0, 2))],
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusText == "Failed / Cancelled" ? Icons.close : Icons.check_circle, 
                            color: Colors.white, size: 12
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText == "Failed / Cancelled" ? "Cancel" : 
                            (statusText == "Completed" || statusText == "Wait Review" ? "Completed" : statusText),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(namaHotel, style: AppTheme.titleStyle.copyWith(fontSize: 16, color: AppTheme.primary)),
                    Text(dateRange, style: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey, fontSize: 12)),
                    const SizedBox(height: 3),
                    Text(formattedCost, style: AppTheme.titleStyle.copyWith(fontSize: 16, color: AppTheme.primary)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 68, height: 68,
                child: SmartImage(path: imageUrl, fit: BoxFit.cover, borderRadius: BorderRadius.circular(12)),
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onActionTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 33,
                      decoration: BoxDecoration(
                        gradient: buttonGradient,
                        color: buttonBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(buttonText, style: TextStyle(color: buttonTextColor, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
              // --- HILANGKAN TOMBOL RECEIPT JIKA CANCELLED ---
              if (statusText != "Failed / Cancelled") ...[
                const SizedBox(width: 11),
                Container(
                  width: 33, height: 33,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    border: Border.all(width: 0.6, color: AppTheme.borderTealLight),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(17),
                      onTap: () => _showBookingDetails(context, ref, booking),
                      child: const Icon(Icons.receipt_long, size: 18, color: AppTheme.primary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuestEmptyState() {
    return _buildEmptyUI('No Booking History Yet', 'Start exploring and book your first stay');
  }

  Widget _buildUserEmptyState(BuildContext context, String category) {
    String message = 'Your past bookings will appear here';
    if (category == 'Completed') message = 'You have not completed any stays yet.';
    if (category == 'Canceled') message = 'You have no canceled bookings.';
    
    return _buildEmptyUI(category == 'All' ? 'No History' : 'No $category History', message);
  }

  Widget _buildEmptyUI(String title, String subtitle) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity, 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Image.asset('assets/images/history_image.png', width: 200, height: 200, fit: BoxFit.contain),
              const SizedBox(height: 24),
              Text(
                title, 
                textAlign: TextAlign.center, 
                style: AppTheme.titleStyle.copyWith(color: AppTheme.deepTeal, fontSize: 18, fontWeight: FontWeight.w800)
              ),
              const SizedBox(height: 10),
              Text(
                subtitle, 
                textAlign: TextAlign.center, 
                style: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 24),
              Container(
                width: 170, height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.softTealGradient, 
                  borderRadius: BorderRadius.circular(20), 
                  boxShadow: [BoxShadow(color: AppTheme.deepTeal.withOpacity(0.24), blurRadius: 10, offset: const Offset(0, 4))]
                ),
                child: ElevatedButton.icon(
                  onPressed: onExploreTap,
                  icon: const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                  label: Text('Explore Hotel', style: AppTheme.bodyStyle.copyWith(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}