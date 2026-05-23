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

    return HotelModel(
      id: json['id_hotel'],
      nama: json['nama_hotel'],
      alamat: json['alamat'] ?? '',
      rating: (json['rating_hotel'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      fasilitas: json['fasilitas_hotel'] ?? json['fasilitas'] ?? [],
      imagePath: imgPath,
    );
  }
}