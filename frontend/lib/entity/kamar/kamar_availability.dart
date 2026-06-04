class KamarAvailability {
  final int idKamar;
  final String namaKamar;
  final int kapasitas;
  final double harga;
  final bool statusAvailable;
  final String availabilityLabel;
  final Map<String, dynamic> data;

  KamarAvailability({
    required this.idKamar,
    required this.namaKamar,
    required this.kapasitas,
    required this.harga,
    required this.statusAvailable,
    required this.availabilityLabel,
    required this.data,
  });

  factory KamarAvailability.fromJson(Map<String, dynamic> json) {
    return KamarAvailability(
      idKamar: json['id_kamar'] ?? 0,
      namaKamar: json['nama_kamar'] ?? '',
      kapasitas: json['kapasitas'] ?? 0,
      harga: (json['harga'] ?? 0) is int
          ? (json['harga'] as int).toDouble()
          : double.tryParse(json['harga'].toString()) ?? 0.0,
      statusAvailable: json['status_available'] ?? false,
      availabilityLabel: json['availability_label'] ?? 'Unavailable',
      data: json['data'] ?? {},
    );
  }
}
