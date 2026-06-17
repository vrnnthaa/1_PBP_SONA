import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sona/entity/pembayaran/pembayaran.dart';
import 'package:sona/pages/pembayaran/verifikasi_pembayaran_page.dart';
import 'package:sona/api/pembayaran/api_pembayaran.dart';

import 'package:sona/providers/auth/token_provider.dart';

import 'package:sona/utils/app_theme.dart';


class RingkasanPembayaranPage extends ConsumerStatefulWidget {
  final int idPemesanan; 
  final double biayaPemesanan;
  final double hargaKamar;
  final String namaKamar;
  final String namaHotel;
  final String checkIn;
  final String checkOut;
  final int jumlahPengunjung;
  final String? imageUrl; 
  final List<Map<String, dynamic>> selectedAddons;

  const RingkasanPembayaranPage({
    super.key,
    required this.idPemesanan,
    required this.biayaPemesanan,
    required this.hargaKamar,
    required this.namaKamar,
    required this.namaHotel,
    required this.checkIn,
    required this.checkOut,
    required this.jumlahPengunjung,
    this.imageUrl,
    required this.selectedAddons
  });

  @override
  ConsumerState<RingkasanPembayaranPage> createState() => _RingkasanPembayaranPageState();
}

class DateUtils {
  
  /// Mengembalikan string berformat "Jan 12 - Jan 14, 2026 (2 nights)"
  static String formatReservationDate(String checkIn, String checkOut) {
    try {
      final DateTime inDate = DateTime.parse(checkIn);
      final DateTime outDate = DateTime.parse(checkOut);
      final int nights = outDate.difference(inDate).inDays;
      
      final String inFormat = DateFormat('MMM dd').format(inDate);
      final String outFormat = DateFormat('MMM dd, yyyy').format(outDate);
      
      return '$inFormat - $outFormat (${nights > 0 ? nights : 1} nights)';
    } catch (e) {
      // Fallback (nilai cadangan) jika format string salah atau gagal di-parse
      return '$checkIn - $checkOut';
    }
  }

  /// Mengembalikan angka jumlah malam (berguna untuk perhitungan harga total)
  static int calculateNights(String checkIn, String checkOut) {
    try {
      final DateTime inDate = DateTime.parse(checkIn);
      final DateTime outDate = DateTime.parse(checkOut);
      final int nights = outDate.difference(inDate).inDays;
      
      return nights > 0 ? nights : 1;
    } catch (e) {
      return 1; // Default minimal 1 malam jika terjadi error
    }
  }
}

class _RingkasanPembayaranPageState extends ConsumerState<RingkasanPembayaranPage> {
  int get _nightCount => DateUtils.calculateNights(widget.checkIn, widget.checkOut);
  double get _hargaKamarTotal => _nightCount * widget.hargaKamar;
  double get _feeAplikasi => 65000.0;
  bool _isLoading = false;

  double get _totalHargaAddons {
    double total = 0.0;
    for (var addon in widget.selectedAddons) {
      total += double.tryParse(addon['harga']?.toString() ?? '0') ?? 0.0;
    }
    return total;
  }

  double get _totalBiaya => widget.biayaPemesanan + _feeAplikasi;

  Future<void> _onPayNow() async {
    setState(() => _isLoading = true);

    try {
      final String? token = ref.read(tokenProvider);

      if(token == null) {
        throw Exception('Sesi telah habis, silahkan login kembali');
      }
      
      Pembayaran createdPembayaran = await ApiPembayaran().storePembayaran(
        idPemesanan: widget.idPemesanan, 
        tanggalPembayaran: DateTime.now(), 
        jumlahBayar: _totalBiaya, 
        statusPembayaran: 'menunggu pembayaran',
        metodePembayaran: 'Transfer Bank',
        token : token,
      );

      if (!mounted) return;
      
      navigateToVerifikasiPayment(createdPembayaran.idPembayaran!);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void navigateToVerifikasiPayment(int generatedIdPembayaran) {

    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => VerifyPaymentPage(
          idPembayaran: generatedIdPembayaran, 
          namaKamar: widget.namaKamar, 
          namaHotel: widget.namaHotel, 
          totalHarga: _totalBiaya,

          deadlineTime: DateTime.now().add(const Duration(hours: 24)), //ini untuk perhitungan 24 jam mundurnya gengs
          imageUrl: widget.imageUrl ?? 'https://via.placeholder.com/150',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('DATA ADD-ONS: ${widget.selectedAddons}');
    
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Booking Summary'),
                  const SizedBox(height: 11),
                  _buildRoomSummaryCard(),
                  
                  const SizedBox(height: 24),
                  _buildReservationDetail(),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Price Breakdown'),
                  const SizedBox(height: 11),
                  _buildPriceDetails(),

                  const SizedBox(height: 11),
                  _buildCancellationPolicy(),
                ],
              ),
            ),
          ),
          _buildBottomAction(_nightCount, _totalBiaya),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.textWhite,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                ),
              ),
              Text(
                'Payment Summary',
                style: GoogleFonts.montserrat(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.titleStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.primary,
      ),
    );
  }

  // Desain kartu yang sudah dirapikan dari BookingImage sebelumnya
  Widget _buildRoomSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              "${widget.imageUrl}", // Ganti dengan widget.pemesanan.imageUrl nanti
              height: 178,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.namaKamar}', // Ganti dengan data dinamis
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Lestari Hotel, Bali',
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetail() {
    final String dateDisplay = DateUtils.formatReservationDate(widget.checkIn, widget.checkOut);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.12)), // Seragam dengan card lainnya
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000), 
            blurRadius: 4, 
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reservation Detail',
            style: AppTheme.titleStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.calendar_month_outlined, 
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Teks Detail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check in - Check Out',
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateDisplay,
                      style: AppTheme.bodyStyle.copyWith(
                        fontSize: 12,
                        color: AppTheme.textDark.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Room (${_nightCount} Nights)', 
            currencyFormatter.format(_hargaKamarTotal)
          ),
          const SizedBox(height: 8),

          if (widget.selectedAddons.isNotEmpty) ...[
            _buildPriceRow(
              'Add-ons', 
              currencyFormatter.format(_totalHargaAddons)
            ),
          const SizedBox(height: 8),
          ],

            _buildPriceRow(
              'Service Fees', 
            currencyFormatter.format(_feeAplikasi)
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payment',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                currencyFormatter.format(_totalBiaya), //Biaya total yang sudah ditambahkan fee
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.titleStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primary.withOpacity(0.8),
          ),
        ),
        Text(
          amount,
          style: AppTheme.titleStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationPolicy() {
    final DateTime now = DateTime.now();
    final DateTime nowDate = DateTime(now.year, now.month, now.day);
    
    DateTime inDateParsed = DateTime.now();
    try {
      inDateParsed = DateTime.parse(widget.checkIn);
    } catch (e) {
      debugPrint('Format checkIn salah: $e');
    }
    final DateTime inDate = DateTime(inDateParsed.year, inDateParsed.month, inDateParsed.day);

    final int daysToCheckIn = inDate.difference(nowDate).inDays;
    
    final bool isFreeCancel = daysToCheckIn >= 2;

    String cancelDateStr = "";
    if (isFreeCancel) {
      final DateTime cancelDate = inDateParsed.subtract(const Duration(days: 2));
      cancelDateStr = DateFormat('dd MMM').format(cancelDate);
    }

    final Color bgColor = isFreeCancel ? const Color(0xFFFDF7F0) : Colors.red.shade50;
    final Color borderColor = isFreeCancel ? const Color(0xFF9E491A) : AppTheme.errorRed.withOpacity(0.5);
    final Color highlightTextColor = isFreeCancel ? const Color(0xFF9E491A) : AppTheme.errorRed;
    final Color normalTextColor = isFreeCancel ? const Color(0xFF9E653F) : AppTheme.errorRed.withOpacity(0.8);

    final String highlightText = isFreeCancel ? 'Free Cancellation ' : 'Non-Refundable. ';
    final String normalText = isFreeCancel 
        ? 'until $cancelDateStr. After that, cancellation fees may apply.'
        : 'Orders made close to the check-in date (H-1 or H-0) cannot be canceled or refunded.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isFreeCancel ? Icons.check_circle_outline : Icons.info_outline,
            color: highlightTextColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.montserrat(
                  fontSize: 12.5,
                  height: 1.5,
                  color: normalTextColor,
                ),
                children: [
                  TextSpan(
                    text: highlightText,
                    style: TextStyle(
                      fontWeight: FontWeight.w700, 
                      color: highlightTextColor,
                    ),
                  ),
                  TextSpan(
                    text: normalText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(int nightCount, double totalBiaya) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.background, 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Teks Atas ---
            Text(
              'SECURE BOOKING GUARANTEED', 
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTealGrey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // --- Tombol Utama ---
            Container(
              width: double.infinity,
              height: 54, 
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft, 
                  end: Alignment.centerRight,
                  colors: [AppTheme.primary, AppTheme.tealLight], 
                ),
                borderRadius: BorderRadius.circular(50), 
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.tealDark.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4), 
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onPayNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 10,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Pay Now',
                        style: AppTheme.titleStyle.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // --- Teks Bawah ---
            Text(
              'by clicking "Confirm & Book Now" you agree to the Terms of\nService and Privacy Policy.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.textTealGrey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}