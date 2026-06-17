import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/entity/review/hotel_review_response.dart';
import 'package:sona/entity/review/review_model.dart';
import 'package:sona/api/review/api_review.dart';
import 'package:sona/api/hotel/api_hotel.dart';
import 'package:sona/pages/review/review_list_page.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/hotel/hotel_amenity_item.dart';
import 'package:sona/widgets/hotel/hotel_gallery_list.dart';
import 'package:sona/widgets/hotel/hotel_location_section.dart';
import 'package:sona/widgets/hotel/hotel_policies_section.dart';
import 'package:sona/widgets/hotel/hotel_price_bottom_bar.dart';
import 'package:sona/widgets/hotel/hotel_review_section.dart';
import 'package:sona/widgets/hotel/section_divider.dart';
import 'package:sona/widgets/home/bookmark_button.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/widgets/loading_animation.dart';
import 'package:sona/widgets/review/review_models.dart';
import 'package:sona/pages/hotels/hotel_location_map_page.dart';
import 'package:sona/pages/kamar/kamar_page.dart';
import 'package:sona/providers/app_providers.dart';

class HotelDetailPage extends ConsumerStatefulWidget {
  final Hotel hotel;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;

  const HotelDetailPage({
    super.key,
    required this.hotel,
    this.checkInDate,
    this.checkOutDate,
    this.guests = 1,
  });

  @override
  ConsumerState<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends ConsumerState<HotelDetailPage> {
  late Hotel hotel;
  int selectedImageIndex = 0;
  late Future<HotelReviewResponse> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    hotel = widget.hotel;
    _reviewsFuture = ApiReview().fetchHotelReviews(hotel.id);
  }

  Future<void> _handleRefresh() async {
    try {
      final updatedHotel = await ApiHotel().fetchHotelById(hotel.id);
      final updatedReviews = ApiReview().fetchHotelReviews(hotel.id);

      if (!mounted) return;

      setState(() {
        hotel = updatedHotel;
        _reviewsFuture = updatedReviews;
      });

      await ref.read(savedHotelsProvider.notifier).loadSavedHotels();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing hotel details: $e')),
      );
    }
  }

  Future<void> _toggleBookmark(Hotel hotel, int idUser) async {
    final success = await ref
        .read(savedHotelsProvider.notifier)
        .toggleSave(hotel, idUser);

    if (!mounted || !success) return;

    final isSavedNow = ref
        .read(savedHotelsProvider)
        .relationMap
        .containsKey(hotel.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSavedNow
              ? '${hotel.nama} bookmarked successfully!'
              : '${hotel.nama} removed from bookmarks',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  List<String> get _galleryImages {
    final images = hotel.daftarGambar
        .map((gambar) => gambar.urlGambar)
        .where((url) => url.isNotEmpty)
        .toList();

    if (images.isEmpty) {
      return ['assets/images/hotel_paradise_resort.jpg'];
    }

    return images;
  }

  String get _mainImage => _galleryImages[selectedImageIndex];

  String _formatPrice(int? price) {
    if (price == null || price <= 0) return 'Price unavailable';

    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    return 'Rp $formatted';
  }

  String _formatReviewDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return '-';
    final date = DateTime.tryParse(rawDate);
    if (date == null) return rawDate;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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

  List<ReviewItemData> _mapToPreviewReviews(List<ReviewModel> reviews) {
    return reviews.map((item) {
      return ReviewItemData(
        reviewerName: item.reviewerName,
        comment: item.komentar,
        rating: item.rating,
      );
    }).toList();
  }

  List<ReviewListItemData> _mapToReviewListItems(List<ReviewModel> reviews) {
    return reviews.map((item) {
      return ReviewListItemData(
        reviewerName: item.reviewerName,
        reviewDate: _formatReviewDate(item.tanggalReview),
        subLabel: null,
        rating: item.rating,
        reviewText: item.komentar,
        reviewImages: item.photoReview != null && item.photoReview!.isNotEmpty
            ? [item.photoReview!]
            : [],
      );
    }).toList();
  }

  void _openAllReviews(HotelReviewResponse reviewData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewListPage(
          title: 'Reviews',
          headerData: ReviewHeaderData(
            title: hotel.nama,
            imagePath: _galleryImages.first,
            rating: reviewData.averageRating,
            location: hotel.alamat,
          ),
          initialReviews: _mapToReviewListItems(reviewData.reviews),
          onRefresh: () async {
            final freshData = await ApiReview().fetchHotelReviews(hotel.id);
            return ReviewRefreshResult(
              averageRating: freshData.averageRating,
              reviews: _mapToReviewListItems(freshData.reviews),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = this.hotel;
    final int? basePrice = hotel.hargaTerendah;

    final savedState = ref.watch(savedHotelsProvider);
    final profileAsync = ref.watch(profileProvider);
    final idUser = profileAsync.valueOrNull?['id_user'] ?? 1;
    final isBookmarked = savedState.relationMap.containsKey(hotel.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      bottomNavigationBar: HotelPriceBottomBar(
        price: basePrice,
        onSelectRoom: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KamarPage(
                idHotel: hotel.id,
                hotelName: hotel.nama,
                checkInDate: widget.checkInDate,
                checkOutDate: widget.checkOutDate,
                guests: widget.guests,
              ),
            ),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.textWhite,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
              title: Text(
                'Booking Hotel',
                style: GoogleFonts.montserrat(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: BookmarkButton(
                      isBookmarked: isBookmarked,
                      onTap: () async {
                        await _toggleBookmark(hotel, idUser);
                      },
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(child: _buildImageGallery()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmenitiesSection(hotel),
                    const SectionDivider(),
                    const SizedBox(height: 16),
                    _buildDescriptionSection(hotel),
                    const SizedBox(height: 18),
                    const SectionDivider(),
                    const SizedBox(height: 16),
                    _buildReviewsSection(),
                    const SizedBox(height: 18),
                    const SectionDivider(),
                    const SizedBox(height: 16),
                    HotelLocationSection(
                      latitude: hotel.latitude,
                      longitude: hotel.longitude,
                      hotelName: hotel.nama,
                      onViewOnMapTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HotelLocationMapPage(
                              latitude: hotel.latitude,
                              longitude: hotel.longitude,
                              hotelName: hotel.nama,
                              priceText: _formatPrice(basePrice),
                              onSelectRoomTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    const SectionDivider(),
                    const SizedBox(height: 16),
                    HotelPoliciesSection(policies: hotel.policies),
                    const SizedBox(height: 18),
                    const SectionDivider(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final hotel = this.hotel;

    return Stack(
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
                  color: AppTheme.textWhite,
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
                      color: AppTheme.textWhite,
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
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(Hotel hotel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 86,
          child: hotel.daftarFasilitas.isEmpty
              ? Center(
                  child: Text(
                    'Amenities not available',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.5,
                      color: AppTheme.textTealMedium,
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: hotel.daftarFasilitas.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final fasilitas = hotel.daftarFasilitas[index];
                    return HotelAmenityItem(
                      label: fasilitas.nama,
                      icon: _resolveFacilityIcon(
                        fasilitas.icon,
                        fasilitas.nama,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Hotel hotel) {
    final isDescriptionLong = hotel.deskripsi.length > 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hotel Description',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          hotel.deskripsi.isNotEmpty ? hotel.deskripsi : '-',
          style: GoogleFonts.montserrat(
            fontSize: 12.5,
            height: 1.55,
            color: AppTheme.textTealMedium,
          ),
          maxLines: isDescriptionLong ? 3 : null,
          overflow: isDescriptionLong ? TextOverflow.ellipsis : null,
        ),
        if (isDescriptionLong) ...[
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: () =>
                  _showFullDescriptionBottomSheet(context, hotel.deskripsi),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.buttonLightTeal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'SEE DETAILS',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showFullDescriptionBottomSheet(
    BuildContext context,
    String description,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderTealLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hotel Description',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.buttonLightTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    height: 1.6,
                    color: AppTheme.textTealMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return FutureBuilder<HotelReviewResponse>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: LoadingAnimation(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const HotelReviewsSection(rating: 0, reviews: []);
        }

        final reviewData = snapshot.data;
        if (reviewData == null) {
          return const HotelReviewsSection(rating: 0, reviews: []);
        }

        final previewReviews = _mapToPreviewReviews(reviewData.reviews);

        return HotelReviewsSection(
          rating: reviewData.averageRating,
          reviews: previewReviews,
          onViewAllTap: () => _openAllReviews(reviewData),
        );
      },
    );
  }
}
