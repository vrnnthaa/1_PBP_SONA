import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/api/hotel/api_save_hotel.dart';
import 'package:sona/providers/auth/token_provider.dart';
import 'package:sona/providers/auth/profile_provider.dart';

// 5. Saved Hotels State Class
class SavedHotelsState {
  final List<Hotel> hotels;
  final Map<int, int> relationMap; // hotelId -> idSaveHotel
  final bool isLoading;

  SavedHotelsState({
    required this.hotels,
    required this.relationMap,
    this.isLoading = false,
  });

  SavedHotelsState copyWith({
    List<Hotel>? hotels,
    Map<int, int>? relationMap,
    bool? isLoading,
  }) {
    return SavedHotelsState(
      hotels: hotels ?? this.hotels,
      relationMap: relationMap ?? this.relationMap,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 6. Saved Hotels StateNotifier Provider
final savedHotelsProvider = StateNotifierProvider<SavedHotelsNotifier, SavedHotelsState>((ref) {
  final token = ref.watch(tokenProvider);
  final profileAsync = ref.watch(profileProvider);
  final idUser = profileAsync.valueOrNull?['id_user'];
  
  return SavedHotelsNotifier(token, idUser);
});

class SavedHotelsNotifier extends StateNotifier<SavedHotelsState> {
  final String? _token;
  final int? _idUser;
  final ApiSaveHotel _apiSaveHotel = ApiSaveHotel();

  SavedHotelsNotifier(this._token, this._idUser) : super(SavedHotelsState(hotels: [], relationMap: {})) {
    loadSavedHotels();
  }

  Future<void> loadSavedHotels() async {
    final token = _token;
    final idUser = _idUser;
    if (token == null || token.isEmpty || idUser == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final list = await _apiSaveHotel.fetchSavedHotels(idUser, token);
      
      final List<Hotel> hotels = [];
      final Map<int, int> relationMap = {};
      
      for (var saveRelation in list) {
        if (saveRelation.hotel != null && saveRelation.isSaved) {
          hotels.add(saveRelation.hotel!);
          relationMap[saveRelation.idHotel] = saveRelation.idSaveHotel;
        }
      }
      
      state = SavedHotelsState(hotels: hotels, relationMap: relationMap, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> toggleSave(Hotel hotel, int idUser) async {
    final token = _token;
    if (token == null || token.isEmpty) return false;
    final isBookmarked = state.relationMap.containsKey(hotel.id);

    if (isBookmarked) {
      final saveId = state.relationMap[hotel.id]!;
      final success = await _apiSaveHotel.toggleSaveHotel(saveId, token);
      if (success) {
        final List<Hotel> updatedHotels = List.from(state.hotels)..removeWhere((h) => h.id == hotel.id);
        final Map<int, int> updatedRelations = Map.from(state.relationMap)..remove(hotel.id);
        state = SavedHotelsState(hotels: updatedHotels, relationMap: updatedRelations, isLoading: false);
        return true;
      }
    } else {
      final success = await _apiSaveHotel.saveHotel(idUser, hotel.id, token);
      if (success) {
        // Reload list to fetch real relationship ID
        await loadSavedHotels();
        return true;
      }
    }
    return false;
  }
}
