import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sona/api/pemesanan/api_pemesanan.dart';
import 'package:sona/pages/pembayaran/ringkasan_pembayaran_page.dart';

// MODEL ADDON (tidak berubah)
class AddonItem {
  final String name;
  final String price;
  final bool isSelected;

  const AddonItem({
    required this.name,
    required this.price,
    this.isSelected = false,
  });
}

class PemesananPage extends StatefulWidget {
  // ← Data yang diterima dari HotelRoomListPage
  final int idKamar;
  final int idUser;
  final String namaKamar;
  final String namaHotel;
  final double hargaPerMalam;
  final DateTimeRange selectedDateRange;
  final int jumlahPengunjung;

  const PemesananPage({
    super.key,
    required this.idKamar,
    required this.idUser,
    required this.namaKamar,
    required this.namaHotel,
    required this.hargaPerMalam,
    required this.selectedDateRange,
    required this.jumlahPengunjung,
  });

  @override
  State<PemesananPage> createState() => _PemesananPageState();
}

class _PemesananPageState extends State<PemesananPage> {
  final ApiPemesanan _apiPemesanan = ApiPemesanan();

  late List<bool> _selectedAddons;
  bool _isLoading = false;

  // Addon dummy — nanti bisa diganti fetch dari API per hotel
  final List<AddonItem> _addons = [
    AddonItem(name: 'Breakfast Included', price: '+ Rp 75.000 / day'),
    AddonItem(name: 'Massages', price: '+ Rp 125.000 / session'),
    AddonItem(name: 'Late Check-out', price: '+ Rp 100.000'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAddons = List.filled(_addons.length, false);
  }

  // Hitung jumlah malam
  int get _jumlahMalam =>
      widget.selectedDateRange.end.difference(widget.selectedDateRange.start).inDays;

  // Hitung total biaya (kamar saja, addon belum dihitung karena masih dummy)
  double get _totalBiaya => widget.hargaPerMalam * _jumlahMalam;

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

  // Tombol "Continue to Summary" ditekan
  Future<void> _onContinue() async {
    setState(() => _isLoading = true);

    try {
      final pemesanan = await _apiPemesanan.storePemesanan(
        idUser: widget.idUser,
        idKamar: widget.idKamar,
        checkIn: _checkInStr,
        checkOut: _checkOutStr,
        jumlahPengunjung: widget.jumlahPengunjung,
        totalBiaya: _totalBiaya,
      );

      if (!mounted) return;

      // Navigasi ke halaman summary, kirim hasil pemesanan
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RingkasanPembayaranPage(pemesanan: pemesanan), // dibuat di bawah
        ),
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected Room'),
                  const SizedBox(height: 11),
                  _buildRoomCard(),       // ← sekarang pakai data real
                  const SizedBox(height: 24),
                  const Text('Add-ons'),
                  const SizedBox(height: 11),
                  _buildAddonList(),
                ],
              ),
            ),
          ),
          _buildBottomSummary(),          // ← total harga real
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(child: Text('Booking')),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withOpacity(0.15)),
        boxShadow: const [
          BoxShadow(color: Color(0x3F000000), blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              'https://placehold.co/320x178',
              height: 178,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ← Nama hotel & kamar dari widget (data real)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.namaHotel}, ${widget.namaKamar}'),
                    const SizedBox(height: 4),
                    Text('Date: $_formattedDateRange'),
                  ],
                ),
                // ← Harga dari widget (data real)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Rp ${widget.hargaPerMalam.toStringAsFixed(0)}'),
                    const Text('/Night'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.15)),
          boxShadow: const [
            BoxShadow(color: Color(0x3F000000), blurRadius: 2, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.circle_outlined, size: 24),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(addon.name),
                    Text(addon.price),
                  ],
                ),
              ],
            ),
            Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked),
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
                  // ← Jumlah malam dihitung otomatis
                  Text('Total for $_jumlahMalam nights'),
                  // ← Total biaya dihitung otomatis
                  Text('Rp ${_totalBiaya.toStringAsFixed(0)}'),
                ],
              ),
              const Text('+Include taxes'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 250,
            height: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF003A3F), Color(0xFF0097A5)],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: TextButton(
                // ← Panggil _onContinue, disable saat loading
                onPressed: _isLoading ? null : _onContinue,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Continue to Summary',
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}