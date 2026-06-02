import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/providers/shared_preferences_provider.dart';

// 2. Token Provider
final tokenProvider = StateNotifierProvider<TokenNotifier, String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TokenNotifier(prefs);
});

class TokenNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  TokenNotifier(this._prefs) : super(_prefs.getString('token'));

  Future<void> setToken(String token) async {
    await _prefs.setString('token', token);
    state = token;
  }

  Future<void> clearToken() async {
    await _prefs.remove('token');
    state = null;
  }
}
