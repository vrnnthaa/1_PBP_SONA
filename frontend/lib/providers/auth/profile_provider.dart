import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/providers/auth/token_provider.dart';
import 'package:sona/api/auth/api_user.dart';

// 3. User Profile Provider
final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final token = ref.watch(tokenProvider);
  if (token == null || token.isEmpty) return null;
  return await ApiUser().fetchProfile(token);
});
