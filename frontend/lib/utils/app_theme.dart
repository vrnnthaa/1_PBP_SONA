import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ==========================================
  // 1. COLORS (Warna Solid)
  // ==========================================
  
  // Warna Utama (Gambar 1)
  static const Color primary = Color(0xFF003A3F);
  static const Color secondary = Color(0xFFDFFEFF);
  static const Color background = Color(0xFFF6F7F9);

  // Warna Teal Shades (Gambar 3)
  static const Color tealDark = Color(0xFF0A585F);
  static const Color tealMedium = Color(0xFF0D6D75);
  static const Color tealLight = Color(0xFF108D98);
  static const Color tealLighter = Color(0xFF13A3AF);

  // Tambahan warna untuk standardisasi intro & map
  static const Color deepTeal = Color(0xFF004D52);
  static const Color accentTeal = Color(0xFF0B9AA4);
  static const Color softCyan = Color(0xFFE6F4F4);
  static const Color textSlate = Color(0xFF94A3B8);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color borderGrey = Color(0xFFEFF3F8);
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color starYellow = Color(0xFFFFC22B);
  static const Color borderTealLight = Color(0xFFCDD8DA);
  static const Color textTealGrey = Color(0xFF6B8A8D);
  static const Color textTealMedium = Color(0xFF4A6568);
  static const Color buttonLightTeal = Color(0xFFE6EDED);
  static const Color gradientCyanEnd = Color(0xFFB9D6D8);

  // ==========================================
  // 2. GRADIENTS (Warna Gradasi)
  // ==========================================
  
  // Contoh gradasi dari warna Primary ke shade Teal paling terang
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,      // #003A3F (Gelap)
      tealLighter,  // #13A3AF (Terang)
    ],
  );

  // Contoh gradasi menggunakan shades (halus)
  static const LinearGradient softTealGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      tealDark,   // #0A585F
      tealLight,  // #108D98
    ],
  );

  // ==========================================
  // 3. FONTS (Teks)
  // ==========================================
  // ==========================================
  // Warna Netral (Teks & Elemen UI)
  // ==========================================
  
  // Hitam elegan (lebih nyaman di mata daripada hitam pekat #000000)
  static const Color textDark = Color(0xFF242833); 
  
  // Abu-abu untuk teks sekunder, subtitle, atau deskripsi
  static const Color textGrey = Color(0xFF929BA8); 
  
  // Abu-abu terang untuk garis batas (border) atau divider
  static const Color borderLight = Color(0xFFEBF0F5); 
  
  // Putih murni
  static const Color textWhite = Colors.white;

  static const Color errorRed = Color(0xFFE53935);

  static const Color textGreen = Color(0xFF003A3F);
  
  static const String fontPrimary = 'Montserrat';
  static const String fontSecondary = 'Roboto';

  // (Opsional) Kamu bisa langsung meracik text style di sini
  // agar tidak perlu ketik ulang di setiap file UI
  static TextStyle titleStyle = GoogleFonts.montserrat(
    color: primary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle titleStyle_white = GoogleFonts.montserrat(
    color: textWhite,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Gunakan GoogleFonts.roboto() untuk font kedua
  static TextStyle bodyStyle = GoogleFonts.roboto(
    color: const Color(0xFF242833),
    fontSize: 14,
  );

  // Contoh tambahan: Style untuk Sub-judul
  static TextStyle subtitleStyle = GoogleFonts.montserrat(
    color: tealDark,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle subtitleStyle_white = GoogleFonts.montserrat(
    color: textWhite,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitleStyle_teal = GoogleFonts.montserrat(
    color: textTealMedium,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
