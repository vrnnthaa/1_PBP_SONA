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

import 'package:sona/pages/pembayaran/pembayaran_sukses_page.dart';
import 'package:sona/widgets/utils/alert_error.dart';
import 'package:sona/widgets/utils/alert_success.dart';

class VerifyPaymentPage extends ConsumerStatefulWidget {
  final int idPembayaran;
  final String namaKamar;
  final String namaHotel;
  final double totalHarga;
  final DateTime deadlineTime;
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

  int _fingerprintAttempts = 0;
  int _pinAttempts = 0;
  bool _isBlocked = false;
  DateTime? _blockUntil;
  Timer? _blockTimer;
  Duration _blockTimeLeft = const Duration();

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
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

  void _startBlockTimer() {
    _blockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_blockUntil != null) {
        final now = DateTime.now();
        if (now.isAfter(_blockUntil!)) {
          setState(() {
            _isBlocked = false;
            _pinAttempts = 0; 
            _fingerprintAttempts = 0; 
            _blockTimer?.cancel();
          });
        } else {
          setState(() {
            _blockTimeLeft = _blockUntil!.difference(now);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _blockTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleExpiredPayment() async {
    final token = ref.read(tokenProvider);
    if (token == null) return;
    try {
      await ApiPembayaran().updateStatusPembayaran(
        widget.idPembayaran,
        statusPembayaran: 'pembayaran gagal',
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
        statusPembayaran: 'pembayaran terverifikasi',
        token: token,
      );
      
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ref.invalidate(bookingsProvider);

      final profile = ref.read(profileProvider).value;
      final userName = profile?['nama'] ?? 'Guest';
      final userPhone = profile?['telp_no'] ?? 'Tidak ada Kontak';
      final userEmail = profile?['email'] ?? 'Tidak ada Email';

      await AlertSuccess.show(
        context: context,
        title: 'Payment Successful!',
        subtitle: 'Your payment has been verified.',
        duration: const Duration(seconds: 2), 
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessPage(
            bookingId: '#SONA-${widget.idPembayaran}', 
            hotelName: widget.namaHotel,
            roomName: widget.namaKamar,
            userName: userName,
            userPhone: userPhone,
            userEmail: userEmail,
            amountPaid: widget.totalHarga,
            paymentMethod: 'Transfer Bank',
            transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
            transactionDate: DateTime.now(),
          ),
        ),
        (route) => route.isFirst,
      );  
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      
      AlertError.show(
        context: context, 
        title: 'Payment Failed', 
        subtitle: 'An error occurred: $e'
      );
    }
  }

  Future<void> _handleScanFingerprint() async {
    if (_isExpired || _isProcessing || _isBlocked || _fingerprintAttempts >= 3) return;

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
        authenticated = true; 
      }
    } catch (e) {
      debugPrint('Error Fingerprint: $e');
    }

    if (authenticated) {
      await _processSuccessfulPayment();
    } else {
      setState(() {
        _fingerprintAttempts++;
      });
      
      if (_fingerprintAttempts >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sidik jari gagal 3 kali. Silakan gunakan Secret PIN.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showPinBottomSheet() {
    if (_isExpired || _isProcessing || _isBlocked) return;

    final token = ref.read(tokenProvider);
    if (token == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return _PinBottomSheet(
          token: token,
          onSuccess: () {
            Navigator.pop(context); 
            _processSuccessfulPayment(); 
          },
          onFailedAttempt: () {
            setState(() {
              _pinAttempts++;
            });
            
            if (_pinAttempts >= 3) {
              Navigator.pop(context); 
              
              setState(() {
                _isBlocked = true;
                _blockUntil = DateTime.now().add(const Duration(minutes: 5));
              });
              _startBlockTimer();
              
              AlertError.show(
                context: context,
                title: 'Account Locked',
                subtitle: 'Too many incorrect attempts. Please try again in 5 minutes.',
                duration: const Duration(seconds: 4),
              );
            }
          },
          sisaPercobaan: 3 - _pinAttempts,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedPrice = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
    ).format(widget.totalHarga);

    String hours = _timeLeft.inHours.toString().padLeft(2, '0');
    String minutes = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    String blockMin = _blockTimeLeft.inMinutes.toString().padLeft(2, '0');
    String blockSec = (_blockTimeLeft.inSeconds % 60).toString().padLeft(2, '0');

    // --- KUNCI 3: MEMBLOKIR TOMBOL BACK BAWAAN HP ---
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false, // --- KUNCI 4: MENGHILANGKAN TOMBOL BACK DI KIRI ATAS ---
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Verify to Pay',
            style: GoogleFonts.montserrat(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const Divider(color: AppTheme.borderLight, height: 1),
                  const SizedBox(height: 24),
                  
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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

                  if (_isBlocked) 
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300, width: 2), 
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: const Icon(Icons.lock_outline_rounded, color: Colors.red, size: 40),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Failed to use Secret PIN\ntry again in $blockMin:$blockSec minutes',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  else 
                    Column(
                      children: [
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
                        
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.borderTealLight, width: 1),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
                              const SizedBox(height: 20),
                              
                              Opacity(
                                opacity: _fingerprintAttempts >= 3 ? 0.5 : 1.0,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: _isExpired || _isProcessing || _fingerprintAttempts >= 3 ? null : _handleScanFingerprint,
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
                              ),
                              
                              const SizedBox(height: 12),
                              
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
                      ],
                    ),

                  const SizedBox(height: 40),
                  // --- KUNCI 5: MENGHILANGKAN TOMBOL 'BACK TO HOME' SEPENUHNYA ---
                ],
              ),
            ),

            if (_isProcessing)
              Container(color: Colors.white.withOpacity(0.8), child: const Center(child: LoadingAnimation())),
          ],
        ),
      ),
    );
  }

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

// ==========================================
// WIDGET KECIL UNTUK BOTTOM SHEET PIN
// ==========================================
class _PinBottomSheet extends StatefulWidget {
  final String token;
  final VoidCallback onSuccess;
  final VoidCallback onFailedAttempt; 
  final int sisaPercobaan; 

  const _PinBottomSheet({
    required this.token, 
    required this.onSuccess, 
    required this.onFailedAttempt,
    required this.sisaPercobaan,
  });

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

    final response = await ApiUser().verifyPin(widget.token, enteredPin);

    setState(() => _isLoading = false);

    if (response['success'] == true) {
      widget.onSuccess(); 
    } else {
      widget.onFailedAttempt();
      
      if (widget.sisaPercobaan > 1) {
        setState(() {
          _errorText = 'PIN salah. Sisa percobaan: ${widget.sisaPercobaan - 1}';
          _pinController.clear();
        });
        _focusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 62, height: 62,
      textStyle: GoogleFonts.montserrat(fontSize: 24, color: AppTheme.primary, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight, width: 1.5),
      ),
    );

    // --- KUNCI 6: MENGUNCI BOTTOM SHEET AGAR TIDAK BISA DITUTUP MANUAL DENGAN GESERAN/BACK ---
    return PopScope(
      canPop: false,
      child: Padding(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Ubah posisi indikator swipe ke tengah
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  // --- KUNCI 7: MENGHAPUS TOMBOL SILANG (CLOSE) DI KANAN ATAS ---
                ],
              ),
              const SizedBox(height: 16), 
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
      ),
    );
  }
}