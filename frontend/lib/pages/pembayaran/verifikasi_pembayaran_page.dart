import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';

import 'package:sona/utils/app_theme.dart';
import 'package:sona/providers/app_providers.dart';
import 'package:sona/api/auth/api_user.dart';
import 'package:sona/api/pembayaran/api_pembayaran.dart';
import 'package:sona/widgets/loading_animation.dart';

class VerifyPaymentPage extends ConsumerStatefulWidget {
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
  ConsumerState<VerifyPaymentPage> createState() => _VerifyPaymentPageState();
}

class _VerifyPaymentPageState extends ConsumerState<VerifyPaymentPage> {
  late Timer _timer;
  Duration _timeLeft = const Duration();
  bool _isExpired = false;
  bool _isProcessing = false;

  final LocalAuthentication _auth = LocalAuthentication();

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
    if (widget.deadlineTime.isBefore(now) && !_isExpired) {
      setState(() {
        _timeLeft = const Duration();
        _isExpired = true;
      });
      _timer.cancel();
      _handleExpiredPayment();
    } else if (!_isExpired) {
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

  Future<void> _handleExpiredPayment() async {
    final token = ref.read(tokenProvider);
    if (token == null) return;

    try {
      await ApiPembayaran().updateStatusPembayaran(
        widget.idPembayaran,
        statusPembayaran: 'pembayaran gagal', // Sesuai enum di database
        token: token,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu pembayaran habis. Transaksi dibatalkan.')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      debugPrint('Gagal update status expired: $e');
    }
  }

  Future<void> _processSuccessfulPayment() async {
    final token = ref.read(tokenProvider);
    if (token == null) return;

    setState(() => _isProcessing = true);

    try {
      await ApiPembayaran().updateStatusPembayaran(
        widget.idPembayaran,
        statusPembayaran: 'pembayaran terverifikasi', // Sesuai enum di database
        token: token,
      );
      
      if (!mounted) return;
      
      // Matikan loading
      setState(() => _isProcessing = false);

      // Munculkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran Berhasil!'),
          backgroundColor: Color(0xFF00BD25),
        ),
      );

      // Refresh data history agar langsung terupdate
      ref.invalidate(bookingsProvider);

      // Kembali ke halaman utama
      Navigator.popUntil(context, (route) => route.isFirst);
      
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: AppTheme.errorRed),
      );
    }
  }

  // FINGERPRINT
  Future<void> _handleScanFingerprint() async {
    if (_isExpired || _isProcessing) return;

    bool authenticated = false;
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      if (canAuthenticateWithBiometrics && isDeviceSupported) {
        authenticated = await _auth.authenticate(
          localizedReason: 'Scan sidik jari untuk mengonfirmasi pembayaran',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
      } else {
        // Fallback jika device tidak support biometrik (langsung sukses untuk testing)
        authenticated = true; 
      }
    } catch (e) {
      debugPrint('Error Fingerprint: $e');
    }

    if (authenticated) {
      await _processSuccessfulPayment();
    }
  }

  // SECRET PIN 
  void _showPinBottomSheet() {
    if (_isExpired || _isProcessing) return;

    final token = ref.read(tokenProvider);
    if (token == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _PinBottomSheet(
          token: token,
          onSuccess: () {
            Navigator.pop(context); // Tutup bottom sheet
            _processSuccessfulPayment(); // Proses bayar ke API
          },
        );
      },
    );
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
      body: Stack(
        children: [
          SingleChildScrollView(
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

                // --- FINGERPRINT ICON ---
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
                    border: Border.all(color: AppTheme.borderTealLight, width: 1, style: BorderStyle.none),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
                      const SizedBox(height: 20),
                      
                      // Button 1: Fingerprint
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isExpired || _isProcessing ? null : _handleScanFingerprint,
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
                      
                      // Button 2: Secret PIN
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isExpired || _isProcessing ? null : _showPinBottomSheet,
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

                TextButton (
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text(
                    'Back To Home',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textTealGrey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Loading Overlay jika API sedang memproses data
          if (_isProcessing)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: LoadingAnimation(),
              ),
            ),
        ],
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

class _PinBottomSheet extends StatefulWidget {
  final String token;
  final VoidCallback onSuccess;

  const _PinBottomSheet({required this.token, required this.onSuccess});

  @override
  State<_PinBottomSheet> createState() => _PinBottomSheetState();
}

class _PinBottomSheetState extends State<_PinBottomSheet> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  String? _errorText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Otomatis memunculkan keyboard saat bottom sheet terbuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    final enteredPin = _pinController.text;
    if (enteredPin.length < 4) {
      setState(() => _errorText = 'PIN tidak lengkap');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // Menembak API user untuk mengecek apakah PIN yang diketik itu valid
    final response = await ApiUser().verifyPin(widget.token, enteredPin);

    setState(() => _isLoading = false);

    if (response['success'] == true) {
      widget.onSuccess(); // Panggil fungsi bayar jika PIN benar
    } else {
      setState(() {
        _errorText = response['message'] ?? 'PIN salah. Coba lagi.';
        _pinController.clear();
      });
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Style Pin Input (Mengambil dari referensi ChangePinPage-mu)
    final defaultPinTheme = PinTheme(
      width: 62, height: 62,
      textStyle: GoogleFonts.montserrat(fontSize: 24, color: AppTheme.primary, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight, width: 1.5),
      ),
    );

    return Padding(
      // Padding ini agar bottom sheet terdorong ke atas saat keyboard muncul
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Enter Secret PIN', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const SizedBox(height: 8),
            Text('To confirm this payment', style: GoogleFonts.roboto(fontSize: 14, color: AppTheme.textTealGrey)),
            const SizedBox(height: 32),
            
            if (_isLoading)
              const LoadingAnimation()
            else
              Pinput(
                length: 4,
                controller: _pinController,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: AppTheme.primary, width: 2))),
                errorPinTheme: defaultPinTheme.copyWith(decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: AppTheme.errorRed, width: 1.5))),
                forceErrorState: _errorText != null,
                obscureText: true,
                onChanged: (val) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
                onCompleted: (val) => _verifyPin(),
              ),

            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_errorText!, style: GoogleFonts.roboto(color: AppTheme.errorRed, fontWeight: FontWeight.w500)),
              ),
              
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}