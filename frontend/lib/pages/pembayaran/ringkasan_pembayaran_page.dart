import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// Sesuaikan import ini dengan struktur folder project-mu
import 'package:sona/utils/app_theme.dart';


class RingkasanPembayaranPage extends StatefulWidget {
  final int idPemesanan; 
  final double biayaPemesanan;
  final double hargaKamar;
  final String namaKamar;
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
    required this.checkIn,
    required this.checkOut,
    required this.jumlahPengunjung,
    this.imageUrl,
    required this.selectedAddons
  });

  @override
  State<RingkasanPembayaranPage> createState() => _RingkasanPembayaranPageState();
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

class _RingkasanPembayaranPageState extends State<RingkasanPembayaranPage> {
  bool _isLoading = false;

  Future<void> _onPayNow() async {
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulasi loading

      if (!mounted) return;
      
      // Navigasi ke halaman sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful!')),
      );
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  _buildSectionTitle('Price Details'),
                  const SizedBox(height: 11),
                  _buildPriceDetails(),
                ],
              ),
            ),
          ),
          _buildBottomAction(),
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
    final int nightCount = DateUtils.calculateNights(widget.checkIn, widget.checkOut);
    final double hargaDisplay = nightCount* widget.hargaKamar; 

    final double feeAplikasi = 65000.0;
    final double totalBiaya = widget.biayaPemesanan + feeAplikasi;//total biaya + fee

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    double totalHargaAddons = 0.0;
    for (var addon in widget.selectedAddons) {
      totalHargaAddons += double.tryParse(addon['harga']?.toString() ?? '0') ?? 0.0;
    }
    
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
            'Room (${nightCount} Nights)', 
            'Rp ${hargaDisplay}'
          ),
          const SizedBox(height: 8),

          if (widget.selectedAddons.isNotEmpty) ...[
            _buildPriceRow(
              'Add-ons', 
              currencyFormatter.format(totalHargaAddons)
            ),
          const SizedBox(height: 8),
          ],

            _buildPriceRow(
              'Service Fees', 
            currencyFormatter.format(feeAplikasi)
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
                currencyFormatter.format(totalBiaya), //Biaya total yang sudah ditambahkan fee
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

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.15))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.tealDark],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: TextButton(
                onPressed: _isLoading ? null : _onPayNow,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Pay Now',
                        style: AppTheme.titleStyle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}