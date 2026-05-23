class HotelCardData {
  final String name;
  final String location;
  final String price;
  final String rating;
  final String imagePath;

  const HotelCardData({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.imagePath,
  });
}

class PlaceData {
  final String name;
  final String imagePath;

  const PlaceData({
    required this.name,
    required this.imagePath,
  });
}

class HotelListData {
  final String name;
  final String location;
  final String imagePath;
  final String price;
  final String rating;

  const HotelListData({
    required this.name,
    required this.location,
    required this.imagePath,
    required this.price,
    required this.rating,
  });
}
