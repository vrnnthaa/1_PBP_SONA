class Fasilitas{
  final int id; 
  final String nama; 
  final String icon; 

  Fasilitas({
    required this.id, 
    required this.nama, 
    required this.icon
  });

  factory Fasilitas.fromJson(Map<String, dynamic> json){
    return Fasilitas(
      id: json['id_fasilitas'] ?? 0, 
      nama: json['nama_fasilitas'] ?? '', 
      icon: json['icon_fasilitas'] ?? '', 
    ); 
  }
}