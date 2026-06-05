import 'package:sona/entity/kamar/kamar.dart';

class KamarAvailability {
  final int idKamar;
  final String namaKamar;
  final int kapasitas;
  final int harga;
  final bool statusAvailable;
  final String availabilityLabel;
  final Kamar? detailKamar;

  KamarAvailability({
    required this.idKamar,
    required this.namaKamar,
    required this.kapasitas,
    required this.harga,
    required this.statusAvailable,
    required this.availabilityLabel,
    required this.detailKamar,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  factory KamarAvailability.fromJson(Map<String, dynamic> json) {
    final detailData = json['data'];

    return KamarAvailability(
      idKamar: _parseInt(json['id_kamar']),
      namaKamar: json['nama_kamar']?.toString() ?? '',
      kapasitas: _parseInt(json['kapasitas']),
      harga: _parseInt(json['harga']),
      statusAvailable: json['status_available'] ?? false,
      availabilityLabel:
          json['availability_label']?.toString() ?? 'Unavailable',
      detailKamar: detailData != null && detailData is Map<String, dynamic>
          ? Kamar.fromJson(detailData)
          : null,
    );
  }
}
