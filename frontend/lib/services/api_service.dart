import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/hotel_model.dart';

class ApiService {
  // PENTING: Atur Base URL sesuai tempatmu menjalankan aplikasi
  // Jika pakai Flutter Web (Chrome), gunakan localhost (127.0.0.1)
  // Jika pakai Android Emulator, localhost Laravel adalah 10.0.2.2
  // Jika pakai HP asli via kabel USB/WiFi, gunakan IP Address laptopmu (misal: 192.168.1.5)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  /// Utility untuk menyesuaikan URL gambar atau asset agar sesuai platform
  static String normalizeUrl(String url) {
    if (kIsWeb) {
      return url.replaceAll('10.0.2.2', 'localhost');
    } else {
      return url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
    }
  }

  // 20 real Yogyakarta hotels from the database SQL dump as a robust fallback
  static final List<HotelModel> fallbackHotels = [
    HotelModel(
      id: 1,
      nama: 'Horison Emerald Timoho',
      alamat: 'Jl. Ipda Tut Harsono No.24, Muja Muju',
      rating: 4.6,
      latitude: -7.7985226,
      longitude: 110.3926422,
      fasilitas: ['Kolam Renang', 'Restoran & Fine Dining'],
      imagePath: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&q=80',
    ),
    HotelModel(
      id: 2,
      nama: 'Gaia Cosmo Hotel',
      alamat: 'Jl. Ipda Tut Harsono No.16, Muja Muju',
      rating: 4.6,
      latitude: -7.7989933,
      longitude: 110.3928022,
      fasilitas: ['Kolam Renang', 'Bar & Lounge'],
      imagePath: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500&q=80',
    ),
    HotelModel(
      id: 3,
      nama: 'POP! Hotel Timoho',
      alamat: 'Jl. Kenari No.11, Muja Muju',
      rating: 4.2,
      latitude: -7.7987041,
      longitude: 110.3914485,
      fasilitas: ['Ruang Rapat & Ballroom', 'Kafe 24 Jam'],
      imagePath: 'https://images.unsplash.com/photo-1598928506311-c55dd580c5b1?w=500&q=80',
    ),
    HotelModel(
      id: 4,
      nama: 'Hotel Tentrem',
      alamat: 'Jl. P. Mangkubumi No.72A, Cokrodiningratan',
      rating: 4.8,
      latitude: -7.7688,
      longitude: 110.3686,
      fasilitas: ['Kolam Renang', 'Pusat Kebugaran (Gym)'],
      imagePath: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=500&q=80',
    ),
    HotelModel(
      id: 5,
      nama: 'Yogyakarta Marriott Hotel',
      alamat: 'Jl. Ring Road Utara, Condongcatur',
      rating: 4.9,
      latitude: -7.7562,
      longitude: 110.3986,
      fasilitas: ['Spa & Pijat', 'Area Parkir Luas'],
      imagePath: 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=500&q=80',
    ),
    HotelModel(
      id: 6,
      nama: 'Royal Ambarrukmo',
      alamat: 'Jl. Laksda Adisucipto No.81, Ambarukmo',
      rating: 4.7,
      latitude: -7.7827,
      longitude: 110.4013,
      fasilitas: ['Taman & Area Terbuka', 'Restoran & Fine Dining'],
      imagePath: 'https://images.unsplash.com/photo-1542314831-c6a4d14b8fc4?w=500&q=80',
    ),
    HotelModel(
      id: 7,
      nama: 'Melia Purosani',
      alamat: 'Jl. Suryotijasan No.31, Ngupasan',
      rating: 4.6,
      latitude: -7.7997,
      longitude: 110.3688,
      fasilitas: ['Kolam Renang', 'Layanan Antar-Jemput'],
      imagePath: 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=500&q=80',
    ),
    HotelModel(
      id: 8,
      nama: 'Ibis Malioboro',
      alamat: 'Jl. Malioboro No.52-58, Suryatmajan',
      rating: 4.5,
      latitude: -7.7932,
      longitude: 110.3658,
      fasilitas: ['WiFi Gratis', 'Area Parkir Luas'],
      imagePath: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&q=80',
    ),
    HotelModel(
      id: 9,
      nama: 'Greenhost Boutique Hotel',
      alamat: 'Jl. Prawirotaman 2 No.629, Brontokusuman',
      rating: 4.5,
      latitude: -7.8183,
      longitude: 110.3697,
      fasilitas: ['Taman & Area Terbuka', 'Kafe 24 Jam'],
      imagePath: 'https://images.unsplash.com/photo-1518733057094-95b5ee1404c3?w=500&q=80',
    ),
    HotelModel(
      id: 10,
      nama: 'ARTOTEL Yogyakarta',
      alamat: 'Jl. Kaliurang KM. 5.6 No.14, Caturtunggal',
      rating: 4.6,
      latitude: -7.7618,
      longitude: 110.3802,
      fasilitas: ['Area Bermain Anak', 'Bar & Lounge'],
      imagePath: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=500&q=80',
    ),
    HotelModel(
      id: 11,
      nama: 'THE 1O1 Yogyakarta Tugu',
      alamat: 'Jl. Margoutomo No.103, Gowongan',
      rating: 4.5,
      latitude: -7.7845,
      longitude: 110.3672,
      fasilitas: ['Kolam Renang', 'Bar & Lounge'],
      imagePath: 'https://images.unsplash.com/photo-1590490359683-658d3d23f972?w=500&q=80',
    ),
    HotelModel(
      id: 12,
      nama: 'The Phoenix Hotel',
      alamat: 'Jl. Jend. Sudirman No.9, Cokrodiningratan',
      rating: 4.7,
      latitude: -7.7831,
      longitude: 110.3670,
      fasilitas: ['Restoran & Fine Dining', 'Taman & Area Terbuka'],
      imagePath: 'https://images.unsplash.com/photo-1551882547-ff40c0d129df?w=500&q=80',
    ),
    HotelModel(
      id: 13,
      nama: 'Hyatt Regency Yogyakarta',
      alamat: 'Jl. Palagan Tentara Pelajar, Ngaglik',
      rating: 4.7,
      latitude: -7.7371,
      longitude: 110.3703,
      fasilitas: ['Kolam Renang', 'Pusat Kebugaran (Gym)'],
      imagePath: 'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=500&q=80',
    ),
    HotelModel(
      id: 14,
      nama: 'The Alana Hotel',
      alamat: 'Jl. Palagan Tentara Pelajar KM 7, Ngaglik',
      rating: 4.6,
      latitude: -7.7335,
      longitude: 110.3758,
      fasilitas: ['Ruang Rapat & Ballroom', 'Pusat Bisnis'],
      imagePath: 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=500&q=80',
    ),
    HotelModel(
      id: 15,
      nama: 'Eastparc Hotel',
      alamat: 'Jl. Laksda Adisucipto KM. 6.5, Seturan',
      rating: 4.8,
      latitude: -7.7797,
      longitude: 110.4093,
      fasilitas: ['Area Bermain Anak', 'Kolam Renang'],
      imagePath: 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=500&q=80',
    ),
    HotelModel(
      id: 16,
      nama: 'Innside by Melia',
      alamat: 'Jl. Ring Road Utara, Maguwoharjo',
      rating: 4.5,
      latitude: -7.7656,
      longitude: 110.4285,
      fasilitas: ['Kolam Renang', 'Pusat Kebugaran (Gym)'],
      imagePath: 'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?w=500&q=80',
    ),
    HotelModel(
      id: 17,
      nama: 'Lafayette Boutique Hotel',
      alamat: 'Jl. Ring Road Utara No.409, Manggung',
      rating: 4.6,
      latitude: -7.7548,
      longitude: 110.3857,
      fasilitas: ['Bar & Lounge', 'Restoran & Fine Dining'],
      imagePath: 'https://images.unsplash.com/photo-1537240923712-bc09e406dd54?w=500&q=80',
    ),
    HotelModel(
      id: 18,
      nama: 'Harper Malioboro',
      alamat: 'Jl. P. Mangkubumi No.52, Gowongan',
      rating: 4.5,
      latitude: -7.7857,
      longitude: 110.3668,
      fasilitas: ['Kafe 24 Jam', 'Spa & Pijat'],
      imagePath: 'https://images.unsplash.com/photo-1608198399988-341cb1703649?w=500&q=80',
    ),
    HotelModel(
      id: 19,
      nama: 'Swiss-Belboutique',
      alamat: 'Jl. Jend. Sudirman No.69, Terban',
      rating: 4.7,
      latitude: -7.7819,
      longitude: 110.3745,
      fasilitas: ['Kolam Renang', 'Bar & Lounge'],
      imagePath: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=500&q=80',
    ),
    HotelModel(
      id: 20,
      nama: 'Jambuluwuk Malioboro',
      alamat: 'Jl. Gajah Mada No.67, Purwokinanti',
      rating: 4.4,
      latitude: -7.8016,
      longitude: 110.3725,
      fasilitas: ['Taman & Area Terbuka', 'Kolam Renang'],
      imagePath: 'https://images.unsplash.com/photo-1560662105-57f8ad6ae2d1?w=500&q=80',
    ),
  ];

  Future<List<HotelModel>> fetchHotels() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/hotels'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Mengambil array di dalam key 'data' (Sesuai return JSON Laravel-mu)
        List<dynamic> hotelList = responseData['data'];
        
        if (hotelList.isNotEmpty) {
          // Ubah list JSON menjadi list dari HotelModel
          return hotelList.map((json) => HotelModel.fromJson(json)).toList();
        }
      }
      throw Exception('Gagal memuat data hotel dari server');
    } catch (e) {
      print('Error fetching hotels, falling back to Yogyakarta SQL dump: $e');
      return List<HotelModel>.from(fallbackHotels); // Return list kosong jika gagal (agar aplikasi tidak crash)
    }
  }
}