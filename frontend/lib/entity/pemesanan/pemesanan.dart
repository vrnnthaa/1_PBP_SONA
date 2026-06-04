class Pemesanan {
  final int idUser;
  final int idKamar;
  final DateTime checkIn;
  final DateTime checkOut;
  final int jumlahPengunjung;
  final double totalBiaya;

  Pemesanan({
    required this.idUser,
    required this.idKamar,
    required this.checkIn,
    required this.checkOut,
    required this.jumlahPengunjung,
    required this.totalBiaya,
  });

  Map<String, dynamic> toJson() => {
    'id_user': idUser,
    'id_kamar': idKamar,
    'check_in': checkIn.toIso8601String(),
    'check_out': checkOut.toIso8601String(),
    'jumlah_pengunjung': jumlahPengunjung,
    'total_biaya': totalBiaya,
  };
}
