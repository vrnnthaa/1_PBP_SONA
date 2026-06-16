import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/pages/hotels/explore_places_hotel_list.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/home/smart_image.dart';

class PlaceViewData {
  final String name;
  final String imagePath;

  const PlaceViewData({required this.name, required this.imagePath});
}

class ViewAllExplorePlacePage extends StatelessWidget {
  final List<Hotel> hotels;

  const ViewAllExplorePlacePage({super.key, required this.hotels});

  static const List<PlaceViewData> _places = [
    PlaceViewData(name: 'Yogyakarta', imagePath: 'assets/images/place_yogyakarta.jpg'),
    PlaceViewData(name: 'Bali', imagePath: 'assets/images/place_bali.jpg'),
    PlaceViewData(name: 'Lombok', imagePath: 'assets/images/place_lombok.jpg'),
    PlaceViewData(name: 'Labuan Bajo', imagePath: 'assets/images/place_labuan_bajo.jpg'),
    PlaceViewData(name: 'Anyer', imagePath: 'assets/images/place_anyer.jpg'),
    PlaceViewData(name: 'Bogor', imagePath: 'assets/images/place_bogor.jpg'),
    PlaceViewData(name: 'Bandung', imagePath: 'assets/images/place_bandung.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Explore Places',
          style: GoogleFonts.montserrat(
            color: AppTheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.borderGrey,
            height: 1,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _places.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final place = _places[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExplorePlacesHotelListPage(
                    hotels: hotels,
                    placeName: place.name,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SmartImage(
                      path: place.imagePath,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.02),
                            Colors.black.withOpacity(0.48),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          place.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
