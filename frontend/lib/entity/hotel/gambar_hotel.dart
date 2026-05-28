class GambarHotel {
  final int idGambar; 
  final int idHotel; 
  final String namaGambar; 
  final String urlGambar; 

  GambarHotel({
    required this.idGambar, 
    required this.idHotel, 
    required this.namaGambar, 
    required this.urlGambar, 
  }); 

  factory GambarHotel.fromJson(Map<String, dynamic> json){
    return GambarHotel(
      idGambar: json['id_gambarhotel'] ?? 0, 
      idHotel: json['id_hotel'] ?? 0, 
      namaGambar: json['nama_gambarhotel'] ?? '', 
      urlGambar: json['url_gambarhotel'] ?? '', 
    ); 
  }
  
}
