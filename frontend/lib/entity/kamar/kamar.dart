import '../master/fasilitas.dart';
import 'gambar_kamar.dart';

class Kamar {
  final int idKamar;
  final String namaKamar;
  final String tipeKamar;
  final double harga;
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

  factory Kamar.fromJson(Map<String, dynamic> json) {
    var listFasilitasJson = json['fasilitas'] as List?;
    List<Fasilitas> listFasilitas = listFasilitasJson != null
        ? listFasilitasJson.map((i) => Fasilitas.fromJson(i)).toList()
        : [];

    var listGambarJson = json['gambar_kamar'] as List?;
    List<GambarKamar> listGambar = listGambarJson != null
        ? listGambarJson.map((i) => GambarKamar.fromJson(i)).toList()
        : [];

    return Kamar(
      idKamar: json['id_kamar'] ?? 0,
      namaKamar: json['nama_kamar'] ?? 'Kamar',
      tipeKamar: json['tipe_kamar'] ?? 'Standard',
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      kapasitas: json['kapasitas'] ?? 1,
      deskripsi: json['deskripsi'] ?? '',
      daftarFasilitas: listFasilitas,
      daftarGambar: listGambar,
    );
  }
}
