import 'hotel.dart';

class SaveHotel{
  final int idSaveHotel;
  final int idUser;
  final int idHotel;
  final bool isSaved;
  final Hotel? hotel;

  SaveHotel({
    required this.idSaveHotel,
    required this.idUser,
    required this.idHotel,
    required this.isSaved,
    this.hotel,
  });

  factory SaveHotel.fromJson(Map<String, dynamic> json) {
    return SaveHotel(
      idSaveHotel: json['id_savehotel'],
      idUser: json['id_user'],
      idHotel: json['id_hotel'],
      isSaved: json['is_saved'] == 1 || json['is_saved'] == true || json['is_saved'] == '1',
      hotel: json['hotel'] != null ? Hotel.fromJson(json['hotel']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_savehotel': idSaveHotel,
      'id_user': idUser,
      'id_hotel': idHotel,
      'is_saved': isSaved ? 1 : 0,
      'hotel': hotel,
    };
  }
}
