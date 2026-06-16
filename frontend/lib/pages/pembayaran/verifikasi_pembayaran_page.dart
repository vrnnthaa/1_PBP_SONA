import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sona/utils/app_theme.dart';

class VerifyPaymentPage extends StatefulWidget {
  final int idPembayaran;
  final String namaKamar;
  final String namaHotel;
  final double totalHarga;
  final DateTime deadlineTime; // Waktu kedaluwarsa (misal: DateTime.now() + 24 jam)
  final String imageUrl;

  const VerifyPaymentPage({
    super.key,
    required this.idPembayaran,
    required this.namaKamar,
    required this.namaHotel,
    required this.totalHarga,
    required this.deadlineTime,
    required this.imageUrl,
  });

  @override
  State<VerifyPaymentPage> createState() => _VerifyPaymentPageState();
}

class _VerifyPaymentPageState extends State<VerifyPaymentPage> {
  late Timer _timer;
  Duration _timeLeft = const Duration();
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    // Memulai timer yang berjalan setiap 1 detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    if (widget.deadlineTime.isBefore(now)) {
      // Waktu habis
      setState(() {
        _timeLeft = const Duration();
        _isExpired = true;
      });
      _timer.cancel();
      // TODO: Panggil ApiPembayaran().updateStatus(..., 'expired', ...)
    } else {
      setState(() {
        _timeLeft = widget.deadlineTime.difference(now);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Wajib batalkan timer saat halaman ditutup
    super.dispose();
  }

  void _handleScanFingerprint() {
    if (_isExpired) return;
    
    // TODO: 
    // 1. Panggil package local_auth untuk scan biometrik
    // 2. Jika sukses, panggil ApiPembayaran().updateStatus(widget.idPembayaran, 'paid', token)
    // 3. Navigator.push ke halaman Sukses
  }

  @override
  Widget build(BuildContext context) {
    // Format harga
    final String formattedPrice = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
    ).format(widget.totalHarga);

    // Ambil jam, menit, detik dari Duration
    String hours = _timeLeft.inHours.toString().padLeft(2, '0');
    String minutes = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.primary),
        title: Text(
          'Verify to Pay',
          style: GoogleFonts.montserrat(
            color: AppTheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(color: AppTheme.borderLight, height: 1),
            const SizedBox(height: 24),
            
            // --- CARD SUMMARY ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: Colors.black.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(widget.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RESERVATION SUMMARY', style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(widget.namaKamar, style: GoogleFonts.montserrat(fontSize: 16, color: AppTheme.primary, fontWeight: FontWeight.w800)),
                        Text(widget.namaHotel, style: GoogleFonts.roboto(fontSize: 12, color: AppTheme.textTealGrey)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // --- COUNTDOWN TIMER ---
            Text('PAYMENT DEADLINE', style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeCircle(hours, 'Hours'),
                const SizedBox(width: 16),
                _buildTimeCircle(minutes, 'Minutes'),
                const SizedBox(width: 16),
                _buildTimeCircle(seconds, 'Seconds'),
              ],
            ),

            const SizedBox(height: 40),

            // --- FINGERPRINT ICON (Tengah) ---
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.background,
                border: Border.all(color: AppTheme.borderTealLight),
              ),
              child: const Icon(Icons.fingerprint, size: 36, color: AppTheme.primary),
            ),

            const SizedBox(height: 24),

            // --- TEXT CONFIRM IDENTITY ---
            Text('Confirm Identity', style: GoogleFonts.montserrat(fontSize: 20, color: AppTheme.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.roboto(fontSize: 13, color: AppTheme.textTealMedium, height: 1.5),
                  children: [
                    const TextSpan(text: 'Please use your fingerprint or enter your secure PIN to authorize the payment of '),
                    TextSpan(text: formattedPrice, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary)),
                    const TextSpan(text: ' for '),
                    TextSpan(text: '${widget.namaHotel}.', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- BOTTOM AREA (Buttons) ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderTealLight, width: 1, style: BorderStyle.none), // Bisa pakai dash package kalau mau putus-putus
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
                  const SizedBox(height: 20),
                  
                  // Scan Fingerprint Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isExpired ? null : _handleScanFingerprint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        icon: const Icon(Icons.fingerprint, color: Colors.white, size: 20),
                        label: Text(
                          'Scan Fingerprint',
                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Enter Secret PIN Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isExpired ? null : () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: Text(
                        'Enter Secret PIN',
                        style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget kecil pembantu untuk Lingkaran Timer
  Widget _buildTimeCircle(String value, String label) {
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppTheme.borderTealLight, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Text(value, style: GoogleFonts.montserrat(fontSize: 22, color: AppTheme.primary, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.roboto(fontSize: 12, color: AppTheme.textTealGrey)),
      ],
    );
  }
}