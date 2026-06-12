import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadFotoService {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  Future<void> uploadDanSimpanKeDB() async {
    try {
      // 1. USER MEMILIH FOTO DARI GALERI
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) {
        print('User batal memilih foto');
        return;
      }

      final File fileFoto = File(pickedFile.path);
      
      // Buat nama file yang unik (misal menggunakan waktu saat ini)
      final String namaFileUnik = 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. UPLOAD FOTO KE SUPABASE STORAGE
      // Pastikan kamu sudah membuat bucket bernama 'hotel_images' di Supabase
      await supabase.storage
          .from('hotel_images')
          .upload(namaFileUnik, fileFoto);

      // 3. DAPATKAN PUBLIC URL DARI STORAGE
      final String publicUrl = supabase.storage
          .from('hotel_images')
          .getPublicUrl(namaFileUnik);

      print('Foto berhasil diupload! URL: $publicUrl');

      // 4. SIMPAN URL TERSEBUT KE DATABASE
      // Asumsi kamu punya tabel 'gambar_hotel' dengan kolom 'url_gambar'
      await supabase.from('gambar_hotel').insert({
        'id_hotel': 1, // Contoh ID hotel
        'url_gambar': publicUrl, // <-- URL foto masuk ke DB di sini
        'nama_gambarhotel': 'Foto Tampilan Depan',
      });

      print('Data berhasil disimpan ke Database!');

    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }
}