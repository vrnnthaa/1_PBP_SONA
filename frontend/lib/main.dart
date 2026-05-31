import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/pages/search/search_results_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sona',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003A3F),
          primary: const Color(0xFF003A3F),
          secondary: const Color(0xFF0B9AA4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        textTheme: GoogleFonts.montserratTextTheme(),
        useMaterial3: true,
      ),
      home: SearchResultsPage(
        location: 'Yogyakarta',
        checkInDate: DateTime(2025, 3, 19),
        checkOutDate: DateTime(2025, 3, 22),
        guests: 1,
      ),
    );
  }
}
