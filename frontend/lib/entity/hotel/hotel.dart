import 'gambar_hotel.dart'; 
import '../master/fasilitas.dart'; 
import '../kamar/kamar.dart';

class Hotel{
  final int id;
  final String nama;
  final String kota; 
  final String alamat;
  final String deskripsi;
  final double rating;
  final double latitude;
  final double longitude;
  
  final List<GambarHotel> daftarGambar; 
  final List<Fasilitas> daftarFasilitas; 
  final List<Kamar> daftarKamar; 

  Hotel({
    required this.id, 
    required this.nama, 
    required this.kota, 
    required this.alamat, 
    required this.deskripsi, 
    required this.rating, 
    required this.latitude, 
    required this.longitude, 
    required this.daftarGambar, 
    required this.daftarFasilitas, 
    required this.daftarKamar, 
  });

  factory Hotel.fromJson(Map<String, dynamic> json){
    var listGambarJson = json['gambar_hotel'] as List?; 
    List<GambarHotel> listGambar = listGambarJson != null
      ? listGambarJson.map((i) => GambarHotel.fromJson(i)).toList()
      : []; 
    
    var listFasilitasJson = json['fasilitas'] as List?; 
    List<Fasilitas> listFasilitas = listFasilitasJson != null
      ? listFasilitasJson.map((i) => Fasilitas.fromJson(i)).toList()
      : []; 
    
    var listKamarJson = json['kamar'] as List?; 
    List<Kamar> listKamar = listKamarJson != null
      ? listKamarJson.map((i) => Kamar.fromJson(i)).toList()
      : []; 
    
    return Hotel(
      id: json['id_hotel'] ?? 0, 
      nama: json['nama_hotel'] ?? 'Unknown', 
      kota: json['kota'] ?? '', 
      alamat: json['alamat'] ?? '', 
      deskripsi: json['deskripsi'], 
      rating: double.tryParse(json['rating_hotel'].toString()) ?? 0.0, 
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,

      daftarGambar: listGambar, 
      daftarFasilitas: listFasilitas, 
      daftarKamar: listKamar
    ); 
  }

  String? get imagePath => daftarGambar.isNotEmpty ? daftarGambar.first.urlGambar : null;
  List<String> get fasilitas => daftarFasilitas.map((f) => f.nama).toList();
}
