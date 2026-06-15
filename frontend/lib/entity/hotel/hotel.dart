import 'gambar_hotel.dart';
import '../master/fasilitas.dart';
import '../kamar/kamar.dart';

class HotelPolicy {
  final String kategori;
  final List<String> items;

  HotelPolicy({required this.kategori, required this.items});

  factory HotelPolicy.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];

    return HotelPolicy(
      kategori: json['kategori'] ?? '',
      items: rawItems.map((e) => e.toString()).toList(),
    );
  }
}

class Hotel {
  final int id;
  final String nama;
  final String kota;
  final String alamat;
  final String deskripsi;
  final double rating;
  final double latitude;
  final double longitude;
  final int? hargaTerendah;

  final List<GambarHotel> daftarGambar;
  final List<Fasilitas> daftarFasilitas;
  final List<Kamar> daftarKamar;
  final List<HotelPolicy> policies;

  Hotel({
    required this.id,
    required this.nama,
    required this.kota,
    required this.alamat,
    required this.deskripsi,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.hargaTerendah,
    required this.daftarGambar,
    required this.daftarFasilitas,
    required this.daftarKamar,
    required this.policies,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final listGambarJson = json['gambar_hotel'] as List?;
    final List<GambarHotel> listGambar = listGambarJson != null
        ? listGambarJson.map((i) => GambarHotel.fromJson(i)).toList()
        : [];

    final listFasilitasJson = json['fasilitas'] as List?;
    final List<Fasilitas> listFasilitas = listFasilitasJson != null
        ? listFasilitasJson.map((i) => Fasilitas.fromJson(i)).toList()
        : [];

    final listKamarJson = json['kamar'] as List?;
    final List<Kamar> listKamar = listKamarJson != null
        ? listKamarJson.map((i) => Kamar.fromJson(i)).toList()
        : [];

    final listPoliciesJson = json['policies'] as List?;
    final List<HotelPolicy> listPolicies = listPoliciesJson != null
        ? listPoliciesJson.map((i) => HotelPolicy.fromJson(i)).toList()
        : [];

    return Hotel(
      id: json['id_hotel'] ?? 0,
      nama: json['nama_hotel'] ?? 'Unknown',
      kota: json['kota'] ?? '',
      alamat: json['alamat'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      rating: double.tryParse(json['rating_hotel'].toString()) ?? 0.0,
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      hargaTerendah: json['harga_terendah'] == null
          ? null
          : int.tryParse(json['harga_terendah'].toString()),
      daftarGambar: listGambar,
      daftarFasilitas: listFasilitas,
      daftarKamar: listKamar,
      policies: listPolicies,
    );
  }

  String? get imagePath =>
      daftarGambar.isNotEmpty ? daftarGambar.first.urlGambar : null;

  List<String> get fasilitas => daftarFasilitas.map((f) => f.nama).toList();
}
