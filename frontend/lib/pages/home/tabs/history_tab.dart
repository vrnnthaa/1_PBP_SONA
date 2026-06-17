import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/providers/auth/profile_provider.dart';

//Widgets
import 'package:sona/widgets/loading_animation.dart';
import 'package:sona/widgets/home/smart_image.dart';

//Pages
import 'package:sona/pages/review/make_review_page.dart';
import 'package:sona/pages/pembayaran/ringkasan_pembayaran_page.dart'; 
import 'package:sona/pages/pembayaran/verifikasi_pembayaran_page.dart'; 

class HistoryTab extends ConsumerWidget {
  final String? token;
  final VoidCallback onExploreTap;

  const HistoryTab({
    super.key,
    required this.token,
    required this.onExploreTap,
  });

  // --- FUNGSI FILTER KATEGORI SESUAI ALUR BARU ---
  String _getBookingCategory(Map<String, dynamic> booking) {
    final statusPemesanan = (booking['status_pemesanan'] ?? 'pending').toString().toLowerCase();
    
    final dynamic paymentData = booking['pembayaran'];
    final Map<String, dynamic>? pembayaran = paymentData is List
        ? (paymentData.isNotEmpty ? paymentData.first : null)
        : (paymentData as Map<String, dynamic>?);
    final statusPembayaran = pembayaran != null ? pembayaran['status_pembayaran']?.toString().toLowerCase() : null;
    //Tab Canceled: Jika batal atau pembayaran gagal
    if (statusPemesanan == 'cancelled' || statusPembayaran == 'pembayaran gagal') {
      return 'Canceled';
    }
    //Tab Completed: Pembayaran selesai, tinggal menunggu review atau sudah di-review
    if (statusPemesanan == 'menunggu review' || statusPemesanan == 'menunggu_review' || 
        statusPemesanan == 'sudah review' || statusPemesanan == 'sudah_review') {
      return 'Completed';
    }
    //Tab Ongoing: Sisanya masuk ke sini (Termasuk belum bayar, menunggu pembayaran, dan booking aktif)
    return 'Ongoing';
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
                  Text(userName, style: AppTheme.titleStyle.copyWith(fontSize: 14)), // Nama dari profile
                ]),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('EMAIL', style: AppTheme.bodyStyle.copyWith(fontSize: 10, color: AppTheme.textGrey)),
                  Text(userEmail, style: AppTheme.titleStyle.copyWith(fontSize: 14)), // Email dari profile
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = token == null || token!.isEmpty;
    final bookingsAsync = ref.watch(bookingsProvider);

    return DefaultTabController(
      length: 4, 
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
            if (!isGuest) // Tombol hanya muncul jika user sudah login
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Refresh Data',
                onPressed: () {
                  // Perintah Riverpod untuk memuat ulang API dari database
                  ref.invalidate(bookingsProvider);
                  
                  // Munculkan notifikasi kecil agar user tahu data sedang diperbarui
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
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
              Tab(text: 'Canceled'),
            ],
          ),
        ),
        body: isGuest
            ? _buildGuestEmptyState()
            : bookingsAsync.when(
                loading: () => const LoadingAnimation(),
                error: (err, stack) => Center(child: Text('Error loading booking history: $err')),
                data: (bookings) {
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(bookingsProvider.future),
                    color: AppTheme.primary,
                    child: TabBarView(
                      children: [
                        _buildBookingList(context, ref, bookings, 'All'),
                        _buildBookingList(context, ref, bookings, 'Ongoing'),
                        _buildBookingList(context, ref, bookings, 'Completed'),
                        _buildBookingList(context, ref, bookings, 'Canceled'),
                      ],
                    ),
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

    if (filteredBookings.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: _buildUserEmptyState(context, categoryFilter),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 92), 
      itemCount: filteredBookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildBookingCard(context, ref, filteredBookings[index]);
      },
    );
  }

  Widget _buildBookingCard(BuildContext context, WidgetRef ref, Map<String, dynamic> booking) {
    final double cost = double.tryParse(booking['total_biaya'].toString()) ?? 0.0;
    final String statusPemesanan = (booking['status_pemesanan'] ?? 'pending').toString().toLowerCase();

    final dynamic paymentData = booking['pembayaran'];
    final Map<String, dynamic>? pembayaran = paymentData is List
        ? (paymentData.isNotEmpty ? paymentData.first : null)
        : (paymentData as Map<String, dynamic>?);
    
    final String? statusPembayaran = pembayaran != null ? pembayaran['status_pembayaran']?.toString().toLowerCase() : null;

    final kamarJson = booking['kamar'];
    final String namaKamar = kamarJson?['nama_kamar'] ?? 'Kamar';    

    final hotelJson = booking['kamar']?['hotel'];
    final String namaHotel = hotelJson?['nama_hotel'] ?? "Unknown Hotel";

    String imageUrl = 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&q=80';

    if (kamarJson != null) {
      final listGambar = kamarJson['gambar_kamar'] as List;
      if (listGambar.isNotEmpty) {
        final gambarPertama = listGambar[0];
        final String? urlDariDb = gambarPertama['url_gambarkamar']?.toString();
        if (urlDariDb != null && urlDariDb.isNotEmpty) imageUrl = urlDariDb;
      }
    }

    final DateTime checkInDate = DateTime.tryParse(booking['check_in'] ?? '') ?? DateTime.now();
    final DateTime checkOutDate = DateTime.tryParse(booking['check_out'] ?? '') ?? DateTime.now();
    final int days = checkOutDate.difference(checkInDate).inDays;

    final String formattedCheckIn = DateFormat('MMM dd', 'en_US').format(checkInDate);
    final String formattedCheckOut = DateFormat('MMM dd', 'en_US').format(checkOutDate);
    final String dateRange = '$formattedCheckIn - $formattedCheckOut, ${checkOutDate.year} • $days ${days > 1 ? 'Days' : 'day'}';

    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    final String formattedCost = currencyFormat.format(cost);

    Color statusColor = AppTheme.primary; 
    String statusText = "Unknown";

    if (statusPemesanan == 'cancelled' || statusPembayaran == 'pembayaran gagal') {
      statusColor = AppTheme.errorRed; 
      statusText = "Failed / Cancelled";
    } else if (statusPembayaran == null) {
      statusColor = AppTheme.starYellow; 
      statusText = "Payment Required";
    } else if (statusPembayaran == 'menunggu pembayaran') {
      statusColor = AppTheme.starYellow; 
      statusText = "Awaiting Payment";
    } else if (statusPemesanan == 'menunggu review' || statusPemesanan == 'menunggu_review') {
      statusColor = const Color.fromARGB(255, 105, 87, 41);
      statusText = "Wait Review";
    } else if (statusPemesanan == 'sudah review' || statusPemesanan == 'sudah_review') {
      statusColor = const Color(0xFF00BD25);
      statusText = "Completed";
    } else if (statusPemesanan == 'aktif' || statusPembayaran == 'pembayaran terverifikasi') {
      statusColor = AppTheme.tealLight;
      statusText = "Active Booking";
    }

    String buttonText = '';
    Color? buttonBgColor;
    Gradient? buttonGradient;
    Color buttonTextColor = Colors.white;
    VoidCallback? onActionTap;

    if (statusText == "Payment Required") {
      buttonText = 'Complete Payment';
      buttonBgColor = AppTheme.primary; 
      onActionTap = () {
        double hargaKamarSatuan = double.tryParse(booking['kamar']?['harga']?.toString() ?? '0') ?? 0.0; 
        int jumlahMalam = days > 0 ? days : 1; 
        double totalHargaKamar = hargaKamarSatuan * jumlahMalam;
        double selisihAddons = cost - totalHargaKamar;
        List<Map<String, dynamic>> addOnsBuatan = [];
        if (selisihAddons > 0) {
          addOnsBuatan.add({
            'nama': 'Add-ons / Fasilitas Tambahan',
            'harga': selisihAddons // Halaman ringkasan akan otomatis menjumlahkan ini
          });
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) => RingkasanPembayaranPage(
          idPemesanan: booking['id_pemesanan'], 
          biayaPemesanan: cost,
          hargaKamar: double.tryParse(booking['kamar']?['harga']?.toString() ?? '0') ?? 0.0,
          namaKamar: namaKamar, 
          namaHotel: namaHotel, 
          checkIn: booking['check_in'],
          checkOut: booking['check_out'], 
          jumlahPengunjung: booking['jumlah_tamu'] ?? 1,
          imageUrl: imageUrl, 
          selectedAddons: addOnsBuatan, 
        )));
      };
    } else if (statusText == "Awaiting Payment") {
      buttonText = 'Verify Payment Now';
      buttonBgColor = AppTheme.starYellow; 
      buttonTextColor = Colors.black87; 
      DateTime tglBuat = DateTime.tryParse(pembayaran?['tanggal_pembayaran'] ?? '') ?? DateTime.now();
      DateTime deadline = tglBuat.add(const Duration(hours: 24));

      onActionTap = () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyPaymentPage(
          idPembayaran: pembayaran!['id_pembayaran'], namaKamar: namaKamar, namaHotel: namaHotel,
          totalHarga: cost, deadlineTime: deadline, imageUrl: imageUrl,
        )));
      };
    } else if (statusText == "Wait Review") {
      buttonText = 'Write a Review';
      buttonGradient = AppTheme.primaryGradient;
      onActionTap = () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MakeReviewPage(booking: booking)));
      };
    } else if (statusText == "Completed") {
      buttonText = 'Already Reviewed'; 
      buttonBgColor = Colors.grey.shade300;
      buttonTextColor = Colors.grey.shade600;
      onActionTap = (){print("Tombol ini tidak memiliki aksi khusus");};
    } else if (statusText == "Failed / Cancelled") {
      buttonText = 'View Cancellation Policy'; 
      buttonBgColor = Colors.grey.shade300;
      buttonTextColor = Colors.grey.shade600;
      onActionTap = (){print("Tombol ini tidak memiliki aksi khusus");};;
    } else {
      buttonText = 'Paid & Active';
      buttonBgColor = Colors.grey.shade300;
      buttonTextColor = Colors.grey.shade600;
      onActionTap = (){print("Tombol ini tidak memiliki aksi khusus");};;
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
                child: GestureDetector(
                  onTap: onActionTap,
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
              const SizedBox(width: 11),
              Container(
                  width: 33, height: 33,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    border: Border.all(width: 0.6, color: AppTheme.borderTealLight),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.receipt_long, size: 18, color: AppTheme.primary),
                    onPressed: () => _showBookingDetails(context, ref, booking), 
                  ),
                ),
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
    if (category == 'Ongoing') message = 'You have no active or ongoing bookings.';
    if (category == 'Completed') message = 'You have not completed any stays yet.';
    if (category == 'Canceled') message = 'You have no canceled bookings.';
    
    return _buildEmptyUI('No $category History', message);
  }

  Widget _buildEmptyUI(String title, String subtitle) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Image.asset('assets/images/history_image.png', width: 200, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 24),
            Text(title, textAlign: TextAlign.center, style: AppTheme.titleStyle.copyWith(color: AppTheme.deepTeal, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(subtitle, textAlign: TextAlign.center, style: AppTheme.bodyStyle.copyWith(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w500)),
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
    );
  }
}