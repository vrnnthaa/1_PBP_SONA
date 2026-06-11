import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/entity/kamar/kamar_availability.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/pages/pemesanan/pemesanan_page.dart';

class RoomDetailPage extends StatefulWidget {
  final KamarAvailability room;
  final DateTimeRange selectedDateRange;

  const RoomDetailPage({
    super.key, 
    required this.room,
    required this.selectedDateRange,
    }); //Izin juga ini, verr

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final PageController _pageController = PageController();
  int _currentImage = 0;

  String _formatPrice(double price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  List<String> _getImages() {
    final gambar = widget.room.detailKamar?.daftarGambar ?? [];
    return gambar
        .map((item) => item.urlGambarKamar)
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  List<String> _getFacilities() {
    return widget.room.detailKamar?.fasilitas ?? [];
  }

  String _getDescription() {
    final desc = widget.room.detailKamar?.deskripsi ?? '';
    if (desc.trim().isEmpty) {
      return 'Comfortable room with complete facilities for your stay.';
    }
    return desc;
  }

  void navigateToBooking(KamarAvailability room) {
    
    final jumlahMalam = widget.selectedDateRange.end.difference(widget.selectedDateRange.start).inDays;
    final totalHarga = room.harga * jumlahMalam;
    
    final listGambar = _getImages();
    final gambarPertama = listGambar.isNotEmpty ? listGambar.first : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PemesananPage(
          idKamar: room.idKamar,
          namaKamar: room.namaKamar,
          hargaTotal: totalHarga,
          idUser: 1, // Ganti dengan ID pengguna yang sesuai
          selectedDateRange: DateTimeRange(
            start: widget.selectedDateRange.start,
            end: widget.selectedDateRange.end,
          ),
          jumlahPengunjung: room.kapasitas,
          imageUrl: gambarPertama,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImages();
    final facilities = _getFacilities();
    final description = _getDescription();

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
                      'Price starts from',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: const Color(0xFF96A3A5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _formatPrice(widget.room.harga),
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: widget.room.statusAvailable ? () => navigateToBooking(widget.room) : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFDDE8E6),
                    foregroundColor: AppTheme.primary,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Select Room',
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
                          widget.room.namaKamar,
                          style: GoogleFonts.montserrat(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.people_outline_rounded,
                              size: 17,
                              color: AppTheme.textTealGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.room.kapasitas} guests',
                              style: GoogleFonts.roboto(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textTealGrey,
                              ),
                            ),
                            const SizedBox(width: 18),
                            const Icon(
                              Icons.square_foot_rounded,
                              size: 17,
                              color: AppTheme.textTealGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '35 m²',
                              style: GoogleFonts.roboto(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textTealGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFD9DFE0)),
                        const SizedBox(height: 14),
                        _buildSectionTitle('Room Facilities'),
                        const SizedBox(height: 10),
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
                        if (facilities.isEmpty)
                          Text(
                            'No facilities information available.',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF6F7F82),
                            ),
                          ),
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFD9DFE0)),
                        const SizedBox(height: 14),
                        _buildSectionTitle('Offer includes'),
                        const SizedBox(height: 8),
                        _buildBullet('Breakfast included'),
                        _buildBullet('Non-refundable'),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 14,
                            top: 2,
                            bottom: 6,
                          ),
                          child: Text(
                            'This special offer includes an extra-low price, but cannot be amended or cancelled.',
                            style: GoogleFonts.roboto(
                              fontSize: 12.5,
                              height: 1.35,
                              color: const Color(0xFF56686B),
                            ),
                          ),
                        ),
                        _buildBullet('Parking'),
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFD9DFE0)),
                        const SizedBox(height: 14),
                        _buildSectionTitle('Occupancy'),
                        const SizedBox(height: 8),
                        _buildBullet('Maximum capacity'),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 14,
                            top: 2,
                            bottom: 8,
                          ),
                          child: Text(
                            '${widget.room.kapasitas} adults',
                            style: GoogleFonts.roboto(
                              fontSize: 12.5,
                              color: const Color(0xFF56686B),
                            ),
                          ),
                        ),
                        _buildBullet('Infant 0-0 year'),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 14,
                            top: 2,
                            bottom: 8,
                          ),
                          child: Text(
                            'Stay for free if using existing bedding.',
                            style: GoogleFonts.roboto(
                              fontSize: 12.5,
                              color: const Color(0xFF56686B),
                            ),
                          ),
                        ),
                        _buildBullet('Children 1-17 year'),
                        Padding(
                          padding: const EdgeInsets.only(left: 14, top: 2),
                          child: Text(
                            'Must use an extra bed. Guests 18 years and older are considered adults.',
                            style: GoogleFonts.roboto(
                              fontSize: 12.5,
                              color: const Color(0xFF56686B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: const Color(0xFFD9DFE0)),
                        const SizedBox(height: 16),
                        _buildReviewHeader(),
                        const SizedBox(height: 12),
                        _buildReviewSummary(),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 122,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 2,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              return _ReviewCard(
                                name: index == 0 ? 'Harry' : 'Andrew',
                                review: index == 0
                                    ? 'The room is clean and the facilities were excellent.'
                                    : 'The room is really friendly and comfortable.',
                                rating: index == 0 ? 4 : 5,
                              );
                            },
                          ),
                        ),
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

  Widget _buildReviewSummary() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0C6A6C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '4.9',
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
              'Excellent',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            Text(
              '48 reviews',
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
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String review;
  final int rating;

  const _ReviewCard({
    required this.name,
    required this.review,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6DEDF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              review,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                fontSize: 13,
                height: 1.35,
                color: const Color(0xFF2F4346),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: const Color(0xFF7D8C8F),
                  ),
                ),
              ),
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: Color(0xFFF5B400),
              ),
              Text(
                '$rating',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );  
  }
}
