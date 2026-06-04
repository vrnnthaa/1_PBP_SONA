import '../master/fasilitas.dart';
import 'gambar_kamar.dart';

class Kamar {
  final int idKamar;
  final String namaKamar;
  final String tipeKamar;
  final int harga;
  final int kapasitas;
  final String deskripsi;
  final List<Fasilitas> daftarFasilitas;
  final List<GambarKamar> daftarGambar;

  Kamar({
    required this.idKamar,
    required this.namaKamar,
    required this.tipeKamar,
    required this.harga,
    required this.kapasitas,
    required this.deskripsi,
    required this.daftarFasilitas,
    required this.daftarGambar,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  factory Kamar.fromJson(Map<String, dynamic> json) {
    final listFasilitasJson =
        (json['fasilitas'] ?? json['fasilitas_kamar']) as List?;

    final List<Fasilitas> listFasilitas = listFasilitasJson != null
        ? listFasilitasJson.map((item) {
            final map = item as Map<String, dynamic>;
            return Fasilitas.fromJson({
              'id_fasilitas':
                  map['id_fasilitaskamar'] ?? map['id_fasilitas'] ?? 0,
              'nama_fasilitas':
                  map['nama_fasilitaskamar'] ?? map['nama_fasilitas'] ?? '',
              'icon_fasilitas':
                  map['icon_fasilitaskamar'] ?? map['icon_fasilitas'] ?? '',
            });
          }).toList()
        : [];

    final listGambarJson =
        (json['gambar_kamar'] ?? json['gambarKamar']) as List?;
    final List<GambarKamar> listGambar = listGambarJson != null
        ? listGambarJson
              .map((i) => GambarKamar.fromJson(i as Map<String, dynamic>))
              .toList()
        : [];

    return Kamar(
      idKamar: _parseInt(json['id_kamar']),
      namaKamar: json['nama_kamar']?.toString() ?? 'Kamar',
      tipeKamar: json['tipe_kamar']?.toString() ?? 'Standard',
      harga: _parseInt(json['harga']),
      kapasitas: _parseInt(json['kapasitas']),
      deskripsi: json['deskripsi']?.toString() ?? '',
      daftarFasilitas: listFasilitas,
      daftarGambar: listGambar,
    );
  }

  List<String> get fasilitas => daftarFasilitas
      .map((f) => f.nama.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}
