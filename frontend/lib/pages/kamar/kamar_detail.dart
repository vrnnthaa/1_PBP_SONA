import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sona/entity/kamar/kamar.dart';
import 'package:sona/entity/kamar/kamar_availability.dart';
import 'package:sona/utils/app_theme.dart';

class RoomDetailPage extends StatefulWidget {
  final KamarAvailability room;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final String hotelName;

  const RoomDetailPage({
    super.key,
    required this.room,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.hotelName,
  });

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final PageController _pageController = PageController();
  int _currentImage = 0;

  Kamar? get _detail => widget.room.detailKamar;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  String _formatShortDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatBookingDateRange() {
    return '${_formatShortDate(widget.checkInDate)} - ${_formatShortDate(widget.checkOutDate)}';
  }

  int _getNightCount() {
    final nights = widget.checkOutDate.difference(widget.checkInDate).inDays;
    return nights > 0 ? nights : 1;
  }

  int _getTotalPrice() {
    return _getPrice() * _getNightCount();
  }

  List<String> _getImages() {
    final gambar = _detail?.daftarGambar ?? [];
    return gambar
        .map((item) => item.urlGambarKamar)
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  List<String> _getFacilities() {
    final fasilitas = _detail?.daftarFasilitas ?? [];

    final fromDetail = fasilitas
        .map((item) => item.toString().trim())
        .where(
          (name) =>
              name.isNotEmpty &&
              name != 'Instance of \'Fasilitas\'' &&
              name != 'Fasilitas',
        )
        .toList();

    if (fromDetail.isNotEmpty) return fromDetail;

    final desc = (_detail?.deskripsi ?? '').toLowerCase();
    final fallback = <String>[];

    if (desc.contains('wifi')) fallback.add('WiFi');
    if (desc.contains('ac') || desc.contains('air conditioning')) {
      fallback.add('Air Conditioning');
    }
    if (desc.contains('breakfast')) fallback.add('Breakfast');
    if (desc.contains('bathroom')) fallback.add('Private Bathroom');
    if (desc.contains('tv')) fallback.add('TV');
    if (desc.contains('shower')) fallback.add('Shower');
    if (desc.contains('balcony')) fallback.add('Balcony');
    if (desc.contains('minibar')) fallback.add('Minibar');

    return fallback;
  }

  List<RoomInfoItem> _getOffers() {
    return _detail?.offer ?? [];
  }

  List<RoomInfoItem> _getOccupancy() {
    return _detail?.occupancy ?? [];
  }

  String _getDescription() {
    final desc = _detail?.deskripsi ?? '';
    if (desc.trim().isEmpty) {
      return 'Comfortable room with complete facilities for your stay.';
    }
    return desc;
  }

  String _getRoomName() {
    final name = (_detail?.namaKamar ?? widget.room.namaKamar).trim();
    return name.isEmpty ? 'Room Detail' : name;
  }

  String _getHotelName() {
    final name = widget.hotelName.trim();
    return name.isEmpty ? 'Hotel' : name;
  }

  int _getPrice() {
    final price = _detail?.harga ?? widget.room.harga;
    return price > 0 ? price : 0;
  }

  int _getCapacity() {
    final capacity = _detail?.kapasitas ?? widget.room.kapasitas;
    return capacity > 0 ? capacity : widget.guests;
  }

  int _getRoomSize() {
    final size = _detail?.ukuranKamar ?? 0;
    return size > 0 ? size : 0;
  }

  double _getRating() {
    final rating = _detail?.ratingKamar ?? 0;
    return rating > 0 ? rating : 0;
  }

  void _handleSelectRoom() {
    if (!widget.room.statusAvailable) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Room selected: ${_getRoomName()}',
          style: GoogleFonts.montserrat(fontSize: 12.5),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // TODO:
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => BookingPage(...),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImages();
    final facilities = _getFacilities();
    final offers = _getOffers();
    final occupancy = _getOccupancy();
    final description = _getDescription();
    final roomName = _getRoomName();
    final hotelName = _getHotelName();
    final roomPrice = _getPrice();
    final roomCapacity = _getCapacity();
    final roomSize = _getRoomSize();
    final roomRating = _getRating();
    final totalPrice = _getTotalPrice();
    final nightCount = _getNightCount();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F5),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.room.statusAvailable
                          ? 'Price summary'
                          : 'Availability status',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: const Color(0xFF96A3A5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (widget.room.statusAvailable) ...[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _formatPrice(roomPrice),
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                            TextSpan(
                              text: ' / Night',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: const Color(0xFFB6BFC1),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total ${_formatPrice(totalPrice)} for $nightCount night${nightCount > 1 ? 's' : ''}',
                        style: GoogleFonts.roboto(
                          fontSize: 12.5,
                          color: AppTheme.textTealGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else
                      Text(
                        widget.room.availabilityLabel.trim().isNotEmpty
                            ? widget.room.availabilityLabel
                            : 'Unavailable',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8A7575),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: widget.room.statusAvailable
                      ? _handleSelectRoom
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: widget.room.statusAvailable
                        ? const Color(0xFFDDE8E6)
                        : Colors.grey.shade200,
                    foregroundColor: widget.room.statusAvailable
                        ? AppTheme.primary
                        : Colors.grey.shade500,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.room.statusAvailable ? 'Select Room' : 'Unavailable',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  Text(
                    'Offer details',
                    style: GoogleFonts.montserrat(
                      color: AppTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildImageSection(images),
                  Container(
                    color: const Color(0xFFF4F5F5),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roomName,
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hotelName,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textTealGrey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBookingSummaryCard(),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 18,
                          runSpacing: 10,
                          children: [
                            _buildMiniInfo(
                              icon: Icons.people_outline_rounded,
                              text: '$roomCapacity guests',
                            ),
                            if (roomSize > 0)
                              _buildMiniInfo(
                                icon: Icons.square_foot_rounded,
                                text: '$roomSize m²',
                              ),
                            if (roomRating > 0)
                              _buildMiniInfo(
                                icon: Icons.star_rounded,
                                text: roomRating.toStringAsFixed(1),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFD9DFE0)),
                        const SizedBox(height: 14),
                        _buildSectionTitle('Description'),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            height: 1.5,
                            color: const Color(0xFF44585B),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFD9DFE0)),
                        const SizedBox(height: 14),
                        _buildSectionTitle('Room Facilities'),
                        const SizedBox(height: 10),
                        if (facilities.isEmpty)
                          Text(
                            'No facilities information available.',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF6F7F82),
                            ),
                          )
                        else
                          ...facilities.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.checkroom_rounded,
                                      size: 18,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF2C3F42),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFD9DFE0)),
                        const SizedBox(height: 14),
                        _buildSectionTitle('Offer includes'),
                        const SizedBox(height: 8),
                        if (offers.isEmpty)
                          Text(
                            'No offer information available.',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF6F7F82),
                            ),
                          )
                        else
                          ...offers.map((item) => _buildInfoBulletItem(item)),
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFD9DFE0)),
                        const SizedBox(height: 14),
                        _buildSectionTitle('Occupancy'),
                        const SizedBox(height: 8),
                        _buildBullet('Selected guests'),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 14,
                            top: 2,
                            bottom: 8,
                          ),
                          child: Text(
                            '${widget.guests} guest${widget.guests > 1 ? 's' : ''}',
                            style: GoogleFonts.roboto(
                              fontSize: 12.5,
                              color: const Color(0xFF56686B),
                            ),
                          ),
                        ),
                        if (occupancy.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'No occupancy information available.',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF6F7F82),
                              ),
                            ),
                          )
                        else
                          ...occupancy.map(
                            (item) => _buildInfoBulletItem(item),
                          ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: const Color(0xFFD9DFE0)),
                        const SizedBox(height: 16),
                        _buildReviewHeader(),
                        const SizedBox(height: 12),
                        _buildReviewSummary(roomRating),
                        const SizedBox(height: 12),
                        _buildReviewPlaceholder(roomRating),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
    final nightCount = _getNightCount();
    final totalPrice = _getTotalPrice();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8DFE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking summary',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.date_range_rounded,
                size: 18,
                color: AppTheme.textTealGrey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatBookingDateRange(),
                  style: GoogleFonts.roboto(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF44585B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.nights_stay_outlined,
                size: 18,
                color: AppTheme.textTealGrey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$nightCount night${nightCount > 1 ? 's' : ''}',
                  style: GoogleFonts.roboto(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF44585B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 18,
                color: AppTheme.textTealGrey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.guests} guest${widget.guests > 1 ? 's' : ''}',
                  style: GoogleFonts.roboto(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF44585B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 18,
                color: AppTheme.textTealGrey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total stay: ${_formatPrice(totalPrice)}',
                  style: GoogleFonts.roboto(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(List<String> images) {
    return SizedBox(
      height: 230,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.isEmpty ? 1 : images.length,
            onPageChanged: (index) {
              setState(() => _currentImage = index);
            },
            itemBuilder: (context, index) {
              if (images.isEmpty) {
                return Container(
                  color: const Color(0xFFE7E7E7),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 34,
                      color: Color(0xFF888888),
                    ),
                  ),
                );
              }

              return Image.network(
                images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFFE7E7E7),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: const Color(0xFFE7E7E7),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 34,
                        color: Color(0xFF888888),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () {
                      final next = (_currentImage + 1) % images.length;
                      _pageController.animateToPage(
                        next,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentImage == index ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentImage == index
                          ? const Color(0xFF0A5C5F)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF344B4E),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF344B4E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBulletItem(RoomInfoItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBullet(item.title),
        if ((item.description ?? '').trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 2, bottom: 8),
            child: Text(
              item.description!,
              style: GoogleFonts.roboto(
                fontSize: 12.5,
                height: 1.35,
                color: const Color(0xFF56686B),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMiniInfo({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppTheme.textTealGrey),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.roboto(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: AppTheme.textTealGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Reviews',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'View All',
            style: GoogleFonts.roboto(
              color: const Color(0xFF4A67B2),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSummary(double rating) {
    final normalizedRating = rating > 0 ? rating : 0.0;
    final ratingLabel = normalizedRating >= 4.5
        ? 'Excellent'
        : normalizedRating >= 4.0
        ? 'Very Good'
        : normalizedRating >= 3.0
        ? 'Good'
        : 'No reviews yet';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0C6A6C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            normalizedRating > 0 ? normalizedRating.toStringAsFixed(1) : '-',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ratingLabel,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            Text(
              normalizedRating > 0
                  ? 'Room rating information'
                  : 'No review data available',
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: const Color(0xFF6B7B7E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewPlaceholder(double rating) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6DEDF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.rate_review_outlined, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rating > 0
                  ? 'Detailed review list belum dihubungkan ke endpoint review kamar.'
                  : 'Belum ada data review kamar yang tersedia untuk ditampilkan.',
              style: GoogleFonts.roboto(
                fontSize: 13.5,
                height: 1.4,
                color: const Color(0xFF2F4346),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
