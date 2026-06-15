class HotelPolicy {
  final String kategori;
  final List<String> items;

  HotelPolicy({required this.kategori, required this.items});

  factory HotelPolicy.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];

    return HotelPolicy(
      kategori: json['kategori'] ?? '',
      items: rawItems.map((e) => e.toString()).toList(),
    );
  }
}
