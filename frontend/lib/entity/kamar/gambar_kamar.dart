class GambarKamar {
  final int idGambarKamar;
  final int idKamar;
  final String namaGambarKamar;
  final String keteranganGambarKamar;
  final String urlGambarKamar;

  GambarKamar({
    required this.idGambarKamar,
    required this.idKamar,
    required this.namaGambarKamar,
    required this.keteranganGambarKamar,
    required this.urlGambarKamar,
  });

  factory GambarKamar.fromJson(Map<String, dynamic> json) {
    return GambarKamar(
      idGambarKamar: json['id_gambarkamar'] ?? 0,
      idKamar: json['id_kamar'] ?? 0,
      namaGambarKamar: json['nama_gambarkamar'] ?? '',
      keteranganGambarKamar: json['keterangan_gambarkamar'] ?? '',
      urlGambarKamar: json['url_gambarkamar'] ?? '',
    );
  }
}
