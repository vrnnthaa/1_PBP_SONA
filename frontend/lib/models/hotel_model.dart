class HotelModel {
  final int id;
  final String nama;
  final String alamat;
  final double rating;
  final double latitude;
  final double longitude;
  final List<dynamic> fasilitas;
  final String? imagePath; // URL of the hotel image from Database

  HotelModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.fasilitas,
    this.imagePath,
  });

  // Factory untuk memetakan JSON dari Laravel ke tipe data Flutter
  factory HotelModel.fromJson(Map<String, dynamic> json) {
    // Cari image dari relation gambar_hotel atau gambarHotel
    final List<dynamic>? gambarList = json['gambar_hotel'] ?? json['gambarHotel'];
    String? imgPath;
    if (gambarList != null && gambarList.isNotEmpty) {
      imgPath = gambarList[0]['url_gambarhotel'];
    }

    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return HotelModel(
      id: json['id_hotel'],
      nama: json['nama_hotel'],
      alamat: json['alamat'] ?? '',
      rating: toDouble(json['rating_hotel']),
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      fasilitas: json['fasilitas_hotel'] ?? json['fasilitas'] ?? [],
      imagePath: imgPath,
    );
  }
}
