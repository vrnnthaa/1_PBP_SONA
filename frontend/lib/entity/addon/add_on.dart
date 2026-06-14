class AddOn {
  final int idPemesanan;
  final String namaAddon;
  final double hargaAddon;
  final String keteranganAddon;

  AddOn({
    required this.idPemesanan,
    required this.namaAddon,
    required this.hargaAddon,
    required this.keteranganAddon,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      idPemesanan: json['id_pemesanan'],
      namaAddon: json['nama_addon'],
      hargaAddon: (json['harga_addon'] as num).toDouble(),
      keteranganAddon: json['keterangan_addon'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id_pemesanan': idPemesanan,
    'nama_addon': namaAddon,
    'harga_addon': hargaAddon,
    'keterangan_addon': keteranganAddon,
  };
}