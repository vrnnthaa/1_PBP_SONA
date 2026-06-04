class ReviewModel {
  final int idReview;
  final int idUser;
  final int idPemesanan;
  final int idHotel;
  final String komentar;
  final double rating;
  final String? photoReview;
  final String? tanggalReview;
  final String reviewerName;
  final String? reviewerPhoto;

  const ReviewModel({
    required this.idReview,
    required this.idUser,
    required this.idPemesanan,
    required this.idHotel,
    required this.komentar,
    required this.rating,
    this.photoReview,
    this.tanggalReview,
    required this.reviewerName,
    this.reviewerPhoto,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    return ReviewModel(
      idReview: int.tryParse(json['id_review'].toString()) ?? 0,
      idUser: int.tryParse(json['id_user'].toString()) ?? 0,
      idPemesanan: int.tryParse(json['id_pemesanan'].toString()) ?? 0,
      idHotel: int.tryParse(json['id_hotel'].toString()) ?? 0,
      komentar: json['komentar']?.toString() ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      photoReview: json['photo_review']?.toString(),
      tanggalReview: json['tanggal_review']?.toString(),
      reviewerName: user?['nama']?.toString() ?? 'Anonymous',
      reviewerPhoto: user?['photo_profile']?.toString(),
    );
  }
}
