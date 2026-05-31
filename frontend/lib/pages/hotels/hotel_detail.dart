import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:sona/api/config/api_config.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/widgets/home/bookmark_button.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/widgets/hotel/hotel_gallery_list.dart';
import 'package:sona/widgets/hotel/hotel_location_section.dart';
import 'package:sona/widgets/hotel/hotel_review_section.dart';

class ApiReview {
  Future<HotelReviewResponse> fetchHotelReviews(int idHotel) async {
    try {
      final response = await get(
        Uri.parse('${ApiConfig.baseUrl}/reviews/hotel/$idHotel'),
        headers: ApiConfig.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return HotelReviewResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Gagal memuat review hotel');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}

class HotelReviewResponse {
  final int idHotel;
  final int totalReview;
  final double averageRating;
  final List<ReviewItemData> reviews;

  const HotelReviewResponse({
    required this.idHotel,
    required this.totalReview,
    required this.averageRating,
    required this.reviews,
  });

  factory HotelReviewResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final reviewsRaw = data['reviews'] as List<dynamic>? ?? [];

    return HotelReviewResponse(
      idHotel: data['id_hotel'] ?? 0,
      totalReview: data['total_review'] ?? 0,
      averageRating: (data['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviews: reviewsRaw.map((item) {
        final review = item as Map<String, dynamic>;
        final user = review['user'] as Map<String, dynamic>?;

        return ReviewItemData(
          reviewerName: user?['nama'] ?? 'Anonymous',
          comment: review['komentar'] ?? '',
          rating: (review['rating'] as num?)?.toDouble(),
        );
      }).toList(),
    );
  }
}

class HotelDetailPage extends StatefulWidget {
  final Hotel hotel;
  final bool initialBookmarked;

  const HotelDetailPage({
    super.key,
    required this.hotel,
    this.initialBookmarked = false,
  });

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  late bool isBookmarked;
  int selectedImageIndex = 0;
  late Future<HotelReviewResponse> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    isBookmarked = widget.initialBookmarked;
    _reviewsFuture = ApiReview().fetchHotelReviews(widget.hotel.id);
  }

  List<String> get _galleryImages {
    final images = widget.hotel.daftarGambar
        .map((gambar) => gambar.urlGambar)
        .where((url) => url.isNotEmpty)
        .toList();

    if (images.isEmpty) {
      return ['assets/images/hotel_paradise_resort.jpg'];
    }

    return images;
  }

  String get _mainImage => _galleryImages[selectedImageIndex];

  String _formatPrice(int hotelId) {
    final steps = [500, 750, 1000, 1250, 1500, 1750, 2000, 2500];
    final price = steps[hotelId % steps.length];
    if (price >= 1000) {
      final millions = price ~/ 1000;
      final remainder = (price % 1000).toString().padLeft(3, '0');
      return 'Rp $millions.$remainder.000';
    }
    return 'Rp $price.000';
  }

  IconData _resolveFacilityIcon(String? value, String fallbackName) {
    final key = (value ?? fallbackName).toLowerCase();
    if (key.contains('pool')) return Icons.pool_rounded;
    if (key.contains('restaurant')) return Icons.restaurant_rounded;
    if (key.contains('local_bar')) return Icons.local_bar_rounded;
    if (key.contains('meeting_room')) return Icons.meeting_room_rounded;
    if (key.contains('local_cafe')) return Icons.local_cafe_rounded;
    if (key.contains('fitness_center') || key.contains('gym')) {
      return Icons.fitness_center_rounded;
    }
    if (key.contains('spa')) return Icons.spa_rounded;
    if (key.contains('wifi')) return Icons.wifi_rounded;
    if (key.contains('local_parking') || key.contains('parking')) {
      return Icons.local_parking_rounded;
    }
    if (key.contains('airport_shuttle')) return Icons.airport_shuttle_rounded;
    if (key.contains('park')) return Icons.park_rounded;
    if (key.contains('business_center')) return Icons.business_center_rounded;
    if (key.contains('child_care')) return Icons.child_care_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F5),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price starts from',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8B999A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _formatPrice(hotel.id),
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF003A3F),
                              ),
                            ),
                            TextSpan(
                              text: ' / Night',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFC2C8C8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDCE6E5),
                      foregroundColor: const Color(0xFF003A3F),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Select Room',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 42,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Color(0xFF003A3F),
                                size: 28,
                              ),
                            ),
                          ),
                          Text(
                            'Booking Hotel',
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFF003A3F),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: BookmarkButton(
                                onTap: () {
                                  setState(() {
                                    isBookmarked = !isBookmarked;
                                  });
                                },
                                isBookmarked: isBookmarked,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    SizedBox(
                      height: 338,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SmartImage(
                            path: _mainImage,
                            fit: BoxFit.cover,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(34),
                              bottomRight: Radius.circular(34),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(34),
                                bottomRight: Radius.circular(34),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0x0D000000),
                                  Color(0x00000000),
                                  Color(0xB3000000),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 20,
                      child: HotelGallerySelector(
                        images: _galleryImages,
                        selectedIndex: selectedImageIndex,
                        onSelected: (index) {
                          setState(() {
                            selectedImageIndex = index;
                          });
                        },
                      ),
                    ),
                    Positioned(
                      left: 28,
                      right: 108,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.nama,
                            style: GoogleFonts.montserrat(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  hotel.alamat,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amenities',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF003A3F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: hotel.daftarFasilitas.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final fasilitas = hotel.daftarFasilitas[index];
                        return _AmenityItem(
                          label: fasilitas.nama,
                          icon: _resolveFacilityIcon(
                            fasilitas.icon,
                            fasilitas.nama,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE0E4E4)),
                  const SizedBox(height: 16),
                  Text(
                    'Hotel Description',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF003A3F),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hotel.deskripsi.isNotEmpty ? hotel.deskripsi : '-',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      height: 1.55,
                      color: const Color(0xFF2C3E40),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE6E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'SEE DETAILS',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF003A3F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: Color(0xFFE0E4E4)),
                  const SizedBox(height: 16),
                  FutureBuilder<HotelReviewResponse>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const HotelReviewsSection(
                          rating: 0,
                          reviews: [],
                        );
                      }

                      final reviewData = snapshot.data;
                      if (reviewData == null) {
                        return const HotelReviewsSection(
                          rating: 0,
                          reviews: [],
                        );
                      }

                      return HotelReviewsSection(
                        rating: reviewData.averageRating,
                        reviews: reviewData.reviews,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: Color(0xFFE0E4E4)),
                  const SizedBox(height: 16),
                  HotelLocationSection(
                    latitude: hotel.latitude,
                    longitude: hotel.longitude,
                    hotelName: hotel.nama,
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: Color(0xFFE0E4E4)),
                  const SizedBox(height: 16),
                  Text(
                    'Accommodation Policies',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF003A3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Check-in & Check-out',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check-in time from 14:00',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Check-out time from 12:00',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Early check-in and late check-out are subject to availability and may incur additional charges.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      height: 1.45,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cancellation & Refund',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Free cancellation is available up to 48 hours before the check-in date.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      height: 1.45,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cancellations made within 48 hours of check-in will be subject to a one-night cancellation fee.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      height: 1.45,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No-show reservations will be charged the full booking amount.',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      height: 1.45,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE6E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Read All',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF003A3F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityItem extends StatelessWidget {
  final String label;
  final IconData icon;

  const _AmenityItem({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Icon(icon, size: 25, color: const Color(0xFF91A5A7)),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF003A3F),
            ),
          ),
        ],
      ),
    );
  }
}
