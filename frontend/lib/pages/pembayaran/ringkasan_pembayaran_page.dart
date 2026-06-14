import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Sesuaikan import ini dengan struktur folder project-mu
import 'package:sona/utils/app_theme.dart';


class RingkasanPembayaranPage extends StatefulWidget {
  final int idPemesanan; 
  final double totalBiaya;
  final String namaKamar;
  final String checkIn;
  final String checkOut;
  final int jumlahPengunjung;
  final String? imageUrl; // Tambahan untuk menampilkan gambar kamar

  const RingkasanPembayaranPage({
    super.key,
    required this.idPemesanan,
    required this.totalBiaya,
    required this.namaKamar,
    required this.checkIn,
    required this.checkOut,
    required this.jumlahPengunjung,
    this.imageUrl, // Optional, bisa null jika tidak ada
  });

  @override
  State<RingkasanPembayaranPage> createState() => _RingkasanPembayaranPageState();
}

class _RingkasanPembayaranPageState extends State<RingkasanPembayaranPage> {
  bool _isLoading = false;
  String _selectedPaymentMethod = 'Bank Transfer'; // Default UI state

  Future<void> _onPayNow() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implementasi Backend untuk proses pembayaran (Midtrans/Xendit/dll)
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
                  _buildSectionTitle('Price Details'),
                  const SizedBox(height: 11),
                  _buildPriceDetails(),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Payment Method'),
                  const SizedBox(height: 11),
                  _buildPaymentMethodSelector(),
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
              "https://placehold.co/320x178", // Ganti dengan widget.pemesanan.imageUrl nanti
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
                  'Deluxe Room', // Ganti dengan data dinamis
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

  Widget _buildPriceDetails() {
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
          _buildPriceRow('Room (2 Nights)', 'Rp 1.500.000'),
          const SizedBox(height: 8),
          _buildPriceRow('Add-ons (Breakfast)', 'Rp 150.000'),
          const SizedBox(height: 8),
          _buildPriceRow('Taxes & Fees', 'Rp 165.000'),
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
                'Rp 1.815.000', // Ganti dengan kalkulasi _formatHarga
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

  Widget _buildPaymentMethodSelector() {
    // UI Sementara untuk pilihan pembayaran
    return GestureDetector(
      onTap: () {
        // Implementasi modal bottom sheet untuk ganti metode pembayaran
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.12)),
          boxShadow: const [
            BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primary),
                const SizedBox(width: 12),
                Text(
                  _selectedPaymentMethod,
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.primary),
          ],
        ),
      ),
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