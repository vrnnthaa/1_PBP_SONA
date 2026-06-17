import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sona/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sona/api/pemesanan/api_pemesanan.dart';
import 'package:sona/pages/pembayaran/ringkasan_pembayaran_page.dart';


class AddonItem {
  final String nama;
  final double harga;
  final String hargaDisplay;
  final String keterangan;
  final bool isPerNight;
  final IconData icon; // <--- Tambahkan ini

  const AddonItem({
    required this.nama,
    required this.hargaDisplay,
    required this.harga,
    required this.keterangan,
    required this.icon, // <--- Tambahkan ini
    this.isPerNight = false,
  });
}

class PemesananPage extends StatefulWidget {
  final int idKamar;
  final int idUser;
  final String namaKamar;
  final String namaHotel;
  final double hargaTotal;
  final double hargaKamar;
  final DateTimeRange selectedDateRange;
  final int jumlahPengunjung;
  final String? imageUrl;

  const PemesananPage({
    super.key,
    required this.idKamar,
    required this.idUser,
    required this.namaKamar,
    required this.namaHotel,
    required this.hargaTotal,
    required this.hargaKamar,
    required this.selectedDateRange,
    required this.jumlahPengunjung,
    this.imageUrl,
  });

  @override
  State<PemesananPage> createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  final ApiPemesanan _apiPemesanan = ApiPemesanan();
  late List<bool> _selectedAddons;
  bool _isLoading = false;


  final List<AddonItem> _addons = [
    AddonItem(
      nama: 'Breakfast Included',
      hargaDisplay: 'Rp 75.000 / day',
      harga: 75000,
      keterangan: 'Breakfast included in your stay',
      isPerNight: true,
      icon: Icons.restaurant, 
    ),
    AddonItem(
      nama: 'Massages',
      hargaDisplay: '+ Rp 125.000 / session',
      harga: 125000,
      keterangan: 'Relaxing massage session',
      isPerNight: false,
      icon: Icons.spa, 
    ),
    AddonItem(
      nama: 'Late Check-out',
      hargaDisplay: 'Rp 100.000',
      harga: 100000,
      keterangan: 'Extend your checkout time',
      isPerNight: false,
      icon: Icons.access_time_filled, 
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAddons = List.filled(_addons.length, false);
  }

  // Hitung jumlah malam
  int get _jumlahMalam => widget.selectedDateRange.end
      .difference(widget.selectedDateRange.start)
      .inDays;

  // Hitung total biaya (kamar saja, addon belum dihitung karena masih dummy)
  double get _totalBiaya {
    double total = widget.hargaTotal;

    if (_selectedAddons[0]) {
      total += (_addons[0].harga * _jumlahMalam);
    }

    if (_selectedAddons[1]) {
      total += _addons[1].harga;
    }

    if (_selectedAddons[2]) {
      total += _addons[2].harga;
    }

    return total;
  } // nanti ditambah harga addon jika ada

  // Format tanggal untuk ditampilkan
  String get _formattedDateRange {
    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(widget.selectedDateRange.start)} - '
        '${formatter.format(widget.selectedDateRange.end)}';
  }

  // Format tanggal untuk dikirim ke API (YYYY-MM-DD)
  String get _checkInStr =>
      DateFormat('yyyy-MM-dd').format(widget.selectedDateRange.start);
  String get _checkOutStr =>
      DateFormat('yyyy-MM-dd').format(widget.selectedDateRange.end);

  // aksi saat "Continue to Summary" ditekan
  Future<void> _navigateToSummaryPaymentPage() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> addonData = [];

      if (_selectedAddons[0]) {
        addonData.add({
          'nama': _addons[0].nama,
          'harga': _addons[0].harga * _jumlahMalam,
          'keterangan': _addons[0].keterangan,
        });
      }

      if (_selectedAddons[1]) {
        addonData.add({
          'nama': _addons[1].nama,
          'harga': _addons[1].harga,
          'keterangan': _addons[1].keterangan,
        });
      }

      if (_selectedAddons[2]) {
        addonData.add({
          'nama': _addons[2].nama,
          'harga': _addons[2].harga,
          'keterangan': _addons[2].keterangan,
        });
      }

      final pemesanan = await _apiPemesanan.storePemesanan(
        idUser: widget.idUser,
        idKamar: widget.idKamar,
        checkIn: _checkInStr,
        checkOut: _checkOutStr,
        jumlahPengunjung: widget.jumlahPengunjung,
        totalBiaya: _totalBiaya,
        addons: addonData,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RingkasanPembayaranPage(
            idPemesanan: pemesanan.idPemesanan,
            biayaPemesanan: _totalBiaya,
            hargaKamar: widget.hargaKamar,
            namaKamar: widget.namaKamar,
            namaHotel: widget.namaHotel,
            checkIn: _checkInStr,
            checkOut: _checkOutStr,
            jumlahPengunjung: widget.jumlahPengunjung,
            imageUrl: widget.imageUrl,
            selectedAddons: addonData,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
                  Text(
                    'Selected Room',
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 11),
                  _buildRoomCard(),
                  const SizedBox(height: 24),
                  Text(
                    'Add-ons',
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 11),
                  _buildAddonList(),
                ],
              ),
            ),
          ),
          _buildBottomSummary(),
        ],
      ),
    );
  }

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
                'Book Your Stay',
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

  Widget _buildFallbackImage() {
    return Container(
      height: 178,
      width: double.infinity,
      color: const Color(0xFFE7E7E7),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 34, color: Color(0xFF888888)),
      ),
    );
  }

  Widget _buildRoomCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                ? Image.network(
                    widget.imageUrl!,
                    height: 178,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackImage(),
                  )
                : _buildFallbackImage(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ← Nama hotel & kamar dari widget (data real)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.namaKamar}',
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: $_formattedDateRange',
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                //Harga dari widget kamar yang dipilih
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${_formatHarga(widget.hargaTotal)}',
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      '/Total',
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
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

  String _formatHarga(double harga) {
    final parts = harga.toStringAsFixed(0).split('');
    final buffer = StringBuffer();

    int count = 0;
    for (int i = parts.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }

  Widget _buildAddonList() {
    return Column(
      children: List.generate(_addons.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildAddonItem(
            addon: _addons[index],
            isSelected: _selectedAddons[index],
            onTap: () => setState(() {
              _selectedAddons[index] = !_selectedAddons[index];
            }),
          ),
        );
      }),
    );
  }

  Widget _buildAddonItem({
    required AddonItem addon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Definisi Gradient untuk saat terpilih
    final Gradient activeGradient = const LinearGradient(
      colors: [AppTheme.primary, AppTheme.tealLight],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: isSelected ? activeGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.black.withOpacity(0.12),
            width: 1,
          ),
          boxShadow: isSelected ? [] : const [
            BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  addon.icon,
                  color: isSelected ? Colors.white : AppTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addon.nama,
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.primary,
                      ),
                    ),
                    Text(
                      addon.hargaDisplay,
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white.withOpacity(0.9) : AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.white : AppTheme.primary,
                  width: 2,
                ),
              ),
              child: isSelected 
                  ? const Icon(Icons.check, size: 16, color: AppTheme.primary) 
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.15))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total for $_jumlahMalam night(s)',
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  // ← Total biaya dihitung otomatis
                  Text(
                    'Rp ${_formatHarga(_totalBiaya)}',
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              Text(
                '+Include taxes',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 250,
            height: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.tealDark],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: TextButton(
                // ← Panggil _onContinue, disable saat loading
                onPressed: _isLoading ? null : _navigateToSummaryPaymentPage,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Continue to Summary',
                        style: AppTheme.titleStyle.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
