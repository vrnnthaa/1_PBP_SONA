import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadReviewFotoService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadFotoReview(File fileFoto) async {
    try {
      // 1. BUAT NAMA FILE YANG UNIK
      final String namaFileUnik = 'review_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. UPLOAD FOTO KE SUPABASE STORAGE
      // Menggunakan bucket bernama 'review' sesuai permintaan
      await supabase.storage
          .from('review')
          .upload(namaFileUnik, fileFoto);

      // 3. DAPATKAN PUBLIC URL DARI STORAGE
      final String publicUrl = supabase.storage
          .from('review')
          .getPublicUrl(namaFileUnik);

      print('Foto review berhasil diupload! URL: $publicUrl');
      return publicUrl;



    } catch (e) {
      print('Terjadi kesalahan saat upload foto review: $e');
      return null;
    }
  }
}
