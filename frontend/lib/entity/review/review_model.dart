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
      idReview: json['id_review'] ?? 0,
      idUser: json['id_user'] ?? 0,
      idPemesanan: json['id_pemesanan'] ?? 0,
      idHotel: json['id_hotel'] ?? 0,
      komentar: json['komentar'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      photoReview: json['photo_review'],
      tanggalReview: json['tanggal_review'],
      reviewerName: user?['nama'] ?? 'Anonymous',
      reviewerPhoto: user?['photo_profile'],
    );
  }
}
