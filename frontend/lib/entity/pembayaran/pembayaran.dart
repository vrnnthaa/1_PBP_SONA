class Pembayaran {
  final int? idPembayaran;
  final int? idPemesanan;
  final DateTime tanggalPembayaran;
  final double jumlahBayar; 
  final String statusPembayaran;
  final String metodePembayaran;

  Pembayaran({
    this.idPembayaran,
    required this.idPemesanan,
    required this.tanggalPembayaran,
    required this.jumlahBayar,
    required this.statusPembayaran,
    required this.metodePembayaran,
  });

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    return Pembayaran(
      idPembayaran: json['id_pembayaran'], 
      idPemesanan: json['id_pemesanan'], 
      tanggalPembayaran: DateTime.parse(json['tanggal_pembayaran']), 
      jumlahBayar: double.parse(json['jumlah_bayar'].toString()), 
      statusPembayaran: json['status_pembayaran'] ?? 'PENDING',
      metodePembayaran: json['metode_Pembayaran'] ?? 'Transfer Bank',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if(idPembayaran != null) 'id_pembayaran': idPembayaran,
      'id_pemesanan' : idPemesanan,
      'tanggal_pembayaran' : "${tanggalPembayaran.year}-${tanggalPembayaran.month.toString().padLeft(2, '0')}-${tanggalPembayaran.day.toString().padLeft(2, '0')}",
      'jumlah_bayar': jumlahBayar,
      'status_pembayaran': statusPembayaran,
      'metode_pembayaran': metodePembayaran,
    };
  }
}