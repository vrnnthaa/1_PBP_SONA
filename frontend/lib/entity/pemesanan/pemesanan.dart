class Pemesanan {
  final int idPemesanan;
  final int idUser;
  final int idKamar;
  final DateTime checkIn;
  final DateTime checkOut;
  final int jumlahPengunjung;
  final double totalBiaya;
  final String statusPemesanan;

  Pemesanan({
    required this.idPemesanan,
    required this.idUser,
    required this.idKamar,
    required this.checkIn,
    required this.checkOut,
    required this.jumlahPengunjung,
    required this.totalBiaya,
    this.statusPemesanan = 'PENDING', // Default status
  });

  factory Pemesanan.fromJson(Map<String, dynamic> json) {
    return Pemesanan(
      idPemesanan: json['id_pemesanan'],
      idUser: json['id_user'],
      idKamar: json['id_kamar'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      jumlahPengunjung: json['jumlah_pengunjung'],
      totalBiaya: (json['total_biaya'] as num).toDouble(),
      statusPemesanan: json['status_pemesanan'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() => {
    'id_pemesanan': idPemesanan,
    'id_user': idUser,
    'id_kamar': idKamar,
    'check_in': checkIn.toIso8601String(),
    'check_out': checkOut.toIso8601String(),
    'jumlah_pengunjung': jumlahPengunjung,
    'total_biaya': totalBiaya,
    'status_pemesanan': statusPemesanan,
  };
}
