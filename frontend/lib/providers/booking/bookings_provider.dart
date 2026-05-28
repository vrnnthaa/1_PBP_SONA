import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/api/booking/api_booking.dart';
import 'package:sona/providers/auth/token_provider.dart';
import 'package:sona/providers/auth/profile_provider.dart';

// 7. Bookings Provider
final bookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final token = ref.watch(tokenProvider);
  final profileAsync = ref.watch(profileProvider);
  final profile = profileAsync.valueOrNull;

  if (token == null || token.isEmpty || profile == null) return [];
  final idUser = profile['id_user'] ?? 1;

  return await ApiBooking().fetchUserBookings(idUser, token);
});
