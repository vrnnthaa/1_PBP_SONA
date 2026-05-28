import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/entity/hotel/gambar_hotel.dart';
import 'package:sona/entity/master/fasilitas.dart';
import 'package:sona/api/hotel/api_hotel.dart';
import 'package:sona/api/hotel/api_save_hotel.dart';
import 'package:sona/api/auth/api_user.dart';
import 'package:sona/api/booking/api_booking.dart';

// 1. SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

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

// 3. User Profile Provider
final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final token = ref.watch(tokenProvider);
  if (token == null || token.isEmpty) return null;
  return await ApiUser().fetchProfile(token);
});

// 4. Hotels Provider (Fetching list of hotels from API with fallbacks)
final hotelsProvider = FutureProvider<List<Hotel>>((ref) async {
  try {
    return await ApiHotel().fetchHotels();
  } catch (e) {
    // Return beautiful fallback hotels matching new Hotel entity
    return _fallbackHotels;
  }
});

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

// 7. Bookings Provider
final bookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final token = ref.watch(tokenProvider);
  final profileAsync = ref.watch(profileProvider);
  final profile = profileAsync.valueOrNull;

  if (token == null || token.isEmpty || profile == null) return [];
  final idUser = profile['id_user'] ?? 1;

  return await ApiBooking().fetchUserBookings(idUser, token);
});

// Fallback Hotels Mock Data
final List<Hotel> _fallbackHotels = [
  Hotel(
    id: 1,
    nama: 'Horison Emerald Timoho',
    kota: 'Yogyakarta',
    alamat: 'Jl. Ipda Tut Harsono No.24, Muja Muju',
    deskripsi: 'Hotel bintang 4 premium dengan kolam renang cantik dan kuliner lezat.',
    rating: 4.6,
    latitude: -7.7985226,
    longitude: 110.3926422,
    daftarGambar: [GambarHotel(idGambar: 1, idHotel: 1, namaGambar: 'img1', urlGambar: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&q=80')],
    daftarFasilitas: [Fasilitas(id: 1, nama: 'Kolam Renang', icon: 'pool'), Fasilitas(id: 2, nama: 'Restoran & Fine Dining', icon: 'restaurant')],
    daftarKamar: [],
  ),
  Hotel(
    id: 2,
    nama: 'Gaia Cosmo Hotel',
    kota: 'Yogyakarta',
    alamat: 'Jl. Ipda Tut Harsono No.16, Muja Muju',
    deskripsi: 'Hotel berdesain industrial modern sangat dekat dengan pusat kota.',
    rating: 4.6,
    latitude: -7.7989933,
    longitude: 110.3928022,
    daftarGambar: [GambarHotel(idGambar: 2, idHotel: 2, namaGambar: 'img2', urlGambar: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500&q=80')],
    daftarFasilitas: [Fasilitas(id: 1, nama: 'Kolam Renang', icon: 'pool'), Fasilitas(id: 3, nama: 'Bar & Lounge', icon: 'bar')],
    daftarKamar: [],
  ),
  Hotel(
    id: 3,
    nama: 'POP! Hotel Timoho',
    kota: 'Yogyakarta',
    alamat: 'Jl. Kenari No.11, Muja Muju',
    deskripsi: 'Hotel budget modern untuk traveler muda.',
    rating: 4.2,
    latitude: -7.7987041,
    longitude: 110.3914485,
    daftarGambar: [GambarHotel(idGambar: 3, idHotel: 3, namaGambar: 'img3', urlGambar: 'https://images.unsplash.com/photo-1598928506311-c55dd580c5b1?w=500&q=80')],
    daftarFasilitas: [Fasilitas(id: 4, nama: 'Ruang Rapat & Ballroom', icon: 'room'), Fasilitas(id: 5, nama: 'Kafe 24 Jam', icon: 'cafe')],
    daftarKamar: [],
  ),
  Hotel(
    id: 4,
    nama: 'Hotel Tentrem',
    kota: 'Yogyakarta',
    alamat: 'Jl. P. Mangkubumi No.72A, Cokrodiningratan',
    deskripsi: 'Kemewahan tradisional Jawa yang mewah.',
    rating: 4.8,
    latitude: -7.7688,
    longitude: 110.3686,
    daftarGambar: [GambarHotel(idGambar: 4, idHotel: 4, namaGambar: 'img4', urlGambar: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=500&q=80')],
    daftarFasilitas: [Fasilitas(id: 1, nama: 'Kolam Renang', icon: 'pool'), Fasilitas(id: 6, nama: 'Pusat Kebugaran (Gym)', icon: 'gym')],
    daftarKamar: [],
  ),
  Hotel(
    id: 5,
    nama: 'Yogyakarta Marriott Hotel',
    kota: 'Yogyakarta',
    alamat: 'Jl. Ring Road Utara, Condongcatur',
    deskripsi: 'Integrasi hotel bintang 5 langsung dengan Hartono Mall.',
    rating: 4.9,
    latitude: -7.7562,
    longitude: 110.3986,
    daftarGambar: [GambarHotel(idGambar: 5, idHotel: 5, namaGambar: 'img5', urlGambar: 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=500&q=80')],
    daftarFasilitas: [Fasilitas(id: 7, nama: 'Spa & Pijat', icon: 'spa'), Fasilitas(id: 8, nama: 'Area Parkir Luas', icon: 'parking')],
    daftarKamar: [],
  ),
];
