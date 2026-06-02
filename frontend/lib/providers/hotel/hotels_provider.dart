import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/api/hotel/api_hotel.dart';

// 4. Hotels Provider (Fetching list of hotels from API)
final hotelsProvider = FutureProvider<List<Hotel>>((ref) async {
  return await ApiHotel().fetchHotels();
});
