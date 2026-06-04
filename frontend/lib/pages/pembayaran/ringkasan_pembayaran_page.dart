import 'package:flutter/material.dart';
import 'package:sona/entity/pemesanan/pemesanan.dart';

class RingkasanPembayaranPage extends StatelessWidget {
  final Pemesanan pemesanan;

  const RingkasanPembayaranPage({super.key, required this.pemesanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Summary')),
      body: Center(
        child: Text('Pemesanan #${pemesanan.idPemesanan} berhasil dibuat!'),
      ),
    );
  }
}