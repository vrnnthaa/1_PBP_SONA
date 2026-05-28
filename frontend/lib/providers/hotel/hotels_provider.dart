import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/entity/hotel/gambar_hotel.dart';
import 'package:sona/entity/master/fasilitas.dart';
import 'package:sona/api/hotel/api_hotel.dart';

// 4. Hotels Provider (Fetching list of hotels from API with fallbacks)
final hotelsProvider = FutureProvider<List<Hotel>>((ref) async {
  try {
    return await ApiHotel().fetchHotels();
  } catch (e) {
    // Return beautiful fallback hotels matching new Hotel entity
    return _fallbackHotels;
  }
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
