import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/providers/app_providers.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = token == null || token!.isEmpty;
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(bookingsProvider.future),
                  color: AppTheme.primary,
                  child: bookings.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height - 180,
                            child: _buildUserEmptyState(context),
                          ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                          itemCount: bookings.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return _buildBookingCard(context, booking);
                          },
                        ),
                );
              },
            ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Map<String, dynamic> booking) {
    
    //Data Pemesanan
    final double cost = double.tryParse(booking['total_biaya'].toString()) ?? 0.0;
    final String statusPemesanan = (booking['status_pemesanan'] ?? 'pending').toString().toLowerCase();

    //Data Pembayaran
    final dynamic paymentData = booking['pembayaran'];
    final Map<String, dynamic>? pembayaran = paymentData is List
        ? (paymentData.isNotEmpty ? paymentData.first : null)
        : (paymentData as Map<String, dynamic>?);
    
    final String? statusPembayaran = pembayaran != null ? pembayaran['status_pembayaran']?.toString().toLowerCase() : null;

    //Data Kamar dan Hotel
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

        if (urlDariDb != null && urlDariDb.isNotEmpty) {
          imageUrl = urlDariDb;
        }
      }
    }

    //Untuk Tanggal
    final DateTime checkInDate = DateTime.tryParse(booking['check_in'] ?? '') ?? DateTime.now();
    final DateTime checkOutDate = DateTime.tryParse(booking['check_out'] ?? '') ?? DateTime.now();
    final int days = checkOutDate.difference(checkInDate).inDays;

    final String formattedCheckIn = DateFormat('MMM dd', 'en_US').format(checkInDate);
    final String formattedCheckOut = DateFormat('MMM dd', 'en_US').format(checkOutDate);
    final String dateRange = '$formattedCheckIn - $formattedCheckOut, ${checkOutDate.year} • $days ${days > 1 ? 'Days' : 'day'}';

    //Untuk Penulisan Rupiah
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp. ', 
      decimalDigits: 0
    );
    final String formattedCost = currencyFormat.format(cost);

    // Untuk Status
    Color statusColor = AppTheme.primary; 
    String statusText = "Unknown";

    // 1. Cek apakah dibatalkan atau gagal bayar
    if (statusPemesanan == 'cancelled' || statusPembayaran == 'pembayaran gagal') {
      statusColor = AppTheme.errorRed; 
      statusText = "Failed / Cancelled";
    } 
    // 2. PRIORITAS PEMBAYARAN: Jika belum ada data pembayaran sama sekali
    else if (statusPembayaran == null) {
      statusColor = AppTheme.starYellow; 
      statusText = "Payment Required";
    } 
    // 3. Jika sudah buat pembayaran, tapi belum verifikasi
    else if (statusPembayaran == 'menunggu pembayaran') {
      statusColor = AppTheme.starYellow; 
      statusText = "Awaiting Payment";
    } 
    // 4. Jika pesanan butuh direview (asumsi pembayaran sudah aman)
    else if (statusPemesanan == 'menunggu review' || statusPemesanan == 'menunggu_review') {
      statusColor = AppTheme.starYellow;
      statusText = "Wait Review";
    } 
    // 5. Jika pesanan sudah selesai dan direview
    else if (statusPemesanan == 'sudah review' || statusPemesanan == 'sudah_review') {
      statusColor = const Color(0xFF00BD25);
      statusText = "Completed";
    } 
    // 6. Jika semua urusan pembayaran beres dan pesanan berjalan
    else if (statusPemesanan == 'aktif' || statusPembayaran == 'pembayaran terverifikasi') {
      statusColor = AppTheme.tealLight;
      statusText = "Active Booking";
    }

    //LOGIKA TOMBOL AKSI DI BAWAH KARTU ---
    String buttonText = '';
    Color? buttonBgColor;
    Gradient? buttonGradient;
    Color buttonTextColor = Colors.white;
    VoidCallback? onActionTap;

    // Menyesuaikan aksi langsung dari statusText yang sudah difilter di atas
    if (statusText == "Payment Required") {
      buttonText = 'Complete Payment';
      buttonBgColor = AppTheme.primary; // Bisa diganti warna orange agar mencolok
      onActionTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RingkasanPembayaranPage(
              idPemesanan: booking['id_pemesanan'],
              biayaPemesanan: cost,
              hargaKamar: double.tryParse(booking['kamar']?['harga_kamar']?.toString() ?? '0') ?? 0.0,
              namaKamar: namaKamar,
              namaHotel: namaHotel,
              checkIn: booking['check_in'],
              checkOut: booking['check_out'],
              jumlahPengunjung: booking['jumlah_tamu'] ?? 1,
              imageUrl: imageUrl,
              selectedAddons: [], 
            ),
          ),
        );
      };
    } 
    else if (statusText == "Awaiting Payment") {
      buttonText = 'Verify Payment Now';
      buttonBgColor = AppTheme.starYellow; 
      buttonTextColor = Colors.black87; 
      
      DateTime tglBuat = DateTime.tryParse(pembayaran?['tanggal_pembayaran'] ?? '') ?? DateTime.now();
      DateTime deadline = tglBuat.add(const Duration(hours: 24));

      onActionTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyPaymentPage(
              idPembayaran: pembayaran!['id_pembayaran'],
              namaKamar: namaKamar,
              namaHotel: namaHotel,
              totalHarga: cost,
              deadlineTime: deadline,
              imageUrl: imageUrl,
            ),
          ),
        );
      };
    } 
    else if (statusText == "Wait Review") {
      buttonText = 'Write a Review';
      buttonGradient = AppTheme.primaryGradient;
      onActionTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MakeReviewPage(booking: booking),
          ),
        );
      };
    } 
    else if (statusText == "Completed") {
      buttonText = 'Reviewed';
      buttonBgColor = Colors.grey.shade300;
      buttonTextColor = Colors.grey.shade600;
      onActionTap = null;
    }
    else if (statusText == "Failed / Cancelled") {
      buttonText = 'Payment Failed';
      buttonBgColor = Colors.grey.shade300;
      buttonTextColor = Colors.grey.shade600;
      onActionTap = null;
    }
    else {
      // Untuk "Active Booking"
      buttonText = 'Paid & Active';
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
        shadows: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 2, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bagian Detail Informasi Hotel & Harga (Tetap sama)
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
          
          // --- TOMBOL DINAMIS YANG SUDAH DIUBAH ---
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onActionTap, // Memanggil fungsi dinamis di atas
                  child: Container(
                    height: 33,
                    decoration: BoxDecoration(
                      gradient: buttonGradient,
                      color: buttonBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: buttonTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
              'images/history_image.png',
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
                  )
                ]
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
}
