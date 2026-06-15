import '../master/fasilitas.dart';
import 'gambar_kamar.dart';

class RoomInfoItem {
  final String title;
  final String? description;

  RoomInfoItem({required this.title, this.description});

  factory RoomInfoItem.fromJson(Map<String, dynamic> json) {
    return RoomInfoItem(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }
}

class Kamar {
  final int idKamar;
  final String namaKamar;
  final String tipeKamar;
  final int harga;
  final int kapasitas;
  final String deskripsi;
  final double ratingKamar;
  final int ukuranKamar;
  final List<RoomInfoItem> offer;
  final List<RoomInfoItem> occupancy;
  final List<Fasilitas> daftarFasilitas;
  final List<GambarKamar> daftarGambar;

  Kamar({
    required this.idKamar,
    required this.namaKamar,
    required this.tipeKamar,
    required this.harga,
    required this.kapasitas,
    required this.deskripsi,
    required this.ratingKamar,
    required this.ukuranKamar,
    required this.offer,
    required this.occupancy,
    required this.daftarFasilitas,
    required this.daftarGambar,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  factory Kamar.fromJson(Map<String, dynamic> json) {
    final rawFasilitas = json['fasilitas'] ?? json['fasilitas_kamar'];
    final listFasilitasJson = rawFasilitas is List ? rawFasilitas : null;

    final List<Fasilitas> listFasilitas = listFasilitasJson != null
        ? listFasilitasJson.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
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

    final rawGambar = json['gambar_kamar'] ?? json['gambarKamar'];
    final listGambarJson = rawGambar is List ? rawGambar : null;

    final List<GambarKamar> listGambar = listGambarJson != null
        ? listGambarJson
              .map(
                (item) => GambarKamar.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList()
        : [];

    final rawOffer = json['offer'];
    final offerJson = rawOffer is List ? rawOffer : const [];

    final rawOccupancy = json['occupancy'];
    final occupancyJson = rawOccupancy is List ? rawOccupancy : const [];

    return Kamar(
      idKamar: _parseInt(json['id_kamar']),
      namaKamar: json['nama_kamar']?.toString() ?? 'Kamar',
      tipeKamar: json['tipe_kamar']?.toString() ?? 'Standard',
      harga: _parseInt(json['harga']),
      kapasitas: _parseInt(json['kapasitas']),
      deskripsi: json['deskripsi']?.toString() ?? '',
      ratingKamar: _parseDouble(json['rating_kamar']),
      ukuranKamar: _parseInt(json['ukuran_kamar']),
      offer: offerJson
          .map(
            (e) => RoomInfoItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      occupancy: occupancyJson
          .map(
            (e) => RoomInfoItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      daftarFasilitas: listFasilitas,
      daftarGambar: listGambar,
    );
  }
}
