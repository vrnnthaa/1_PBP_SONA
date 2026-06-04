class ReviewListItemData {
  final String reviewerName;
  final String reviewDate;
  final String? subLabel;
  final double rating;
  final String reviewText;
  final List<String> reviewImages;

  const ReviewListItemData({
    required this.reviewerName,
    required this.reviewDate,
    this.subLabel,
    required this.rating,
    required this.reviewText,
    this.reviewImages = const [],
  });
}

class ReviewHeaderData {
  final String title;
  final String imagePath;
  final double rating;
  final String? location;
  final String? guestInfo;
  final String? roomSize;
  final List<String> tags;

  const ReviewHeaderData({
    required this.title,
    required this.imagePath,
    required this.rating,
    this.location,
    this.guestInfo,
    this.roomSize,
    this.tags = const [],
  });

  bool get isRoomMode =>
      guestInfo != null || roomSize != null || tags.isNotEmpty;
}
