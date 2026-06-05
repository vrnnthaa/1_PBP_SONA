import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sona/entity/kamar/kamar_availability.dart';
import 'package:sona/utils/app_theme.dart';

class KamarCard extends StatelessWidget {
  final KamarAvailability room;
  final VoidCallback? onSelectRoom;

  const KamarCard({super.key, required this.room, required this.onSelectRoom});

  String _formatPrice(double price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  List<String> _getFacilities() {
    return room.detailKamar?.fasilitas ?? [];
  }

  List<String> _getImages() {
    final gambar = room.detailKamar?.daftarGambar ?? [];
    return gambar
        .map((item) => item.urlGambarKamar)
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  String _getDescription() {
    final desc = room.detailKamar?.deskripsi ?? '';
    if (desc.trim().isEmpty) {
      return 'Comfortable room with modern facilities for your stay.';
    }
    return desc;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = room.statusAvailable;
    final facilities = _getFacilities();
    final images = _getImages();
    final description = _getDescription();

    debugPrint('ROOM: ${room.namaKamar}');
    debugPrint('DETAIL ADA: ${room.detailKamar != null}');
    debugPrint(
      'JUMLAH FASILITAS RAW: ${room.detailKamar?.daftarFasilitas.length}',
    );
    debugPrint('FASILITAS GETTER: ${room.detailKamar?.fasilitas}');
    return Opacity(
      opacity: isAvailable ? 1 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image carousel ──────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: _RoomImageCarousel(images: images),
            ),

            // ── Content ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          room.namaKamar,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            letterSpacing: -0.2,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(0xFF004D4F)
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Unavailable',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Description
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: const Color(0xFF8B9A9D),
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Guests + area
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        size: 14,
                        color: AppTheme.textTealGrey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${room.kapasitas} guests',
                        style: GoogleFonts.roboto(
                          color: AppTheme.textTealGrey,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.square_foot_rounded,
                        size: 14,
                        color: AppTheme.textTealGrey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '35 m²',
                        style: GoogleFonts.roboto(
                          color: AppTheme.textTealGrey,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Facilities chips
                  if (facilities.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 30,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: facilities.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          final fasilitas = facilities[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F5F5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE0E6E6),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                fasilitas,
                                style: GoogleFonts.roboto(
                                  fontSize: 10.5,
                                  color: const Color(0xFF4E6367),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Divider tipis
                  Container(height: 1, color: const Color(0xFFF0F2F2)),

                  const SizedBox(height: 12),

                  // Price + button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Room Price',
                              style: GoogleFonts.roboto(
                                fontSize: 10.5,
                                color: const Color(0xFFABB5B7),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: _formatPrice(room.harga),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / Night',
                                    style: GoogleFonts.roboto(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFB8C0C2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: isAvailable ? onSelectRoom : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable
                                ? const Color(0xFFD8E8E5)
                                : Colors.grey.shade200,
                            foregroundColor: isAvailable
                                ? AppTheme.primary
                                : Colors.grey.shade500,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade500,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: Text(
                            isAvailable ? 'Select Room' : 'Unavailable',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
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
      ),
    );
  }
}

class _RoomImageCarousel extends StatefulWidget {
  final List<String> images;

  const _RoomImageCarousel({required this.images});

  @override
  State<_RoomImageCarousel> createState() => _RoomImageCarouselState();
}

class _RoomImageCarouselState extends State<_RoomImageCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.images.isNotEmpty;
    final itemCount = hasImages ? widget.images.length : 2;

    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: itemCount,
            padEnds: false,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final bool hasRealImage =
                  hasImages && index < widget.images.length;
              return Padding(
                padding: EdgeInsets.only(right: index == itemCount - 1 ? 0 : 6),
                child: hasRealImage
                    ? Image.network(
                        widget.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallback(),
                      )
                    : _buildFallback(),
              );
            },
          ),
          if (itemCount > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  itemCount,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: _currentIndex == index ? 16 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? const Color(0xFF0A5C5F)
                          : Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFFE7E7E7),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 28, color: Color(0xFF888888)),
      ),
    );
  }
}
