import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/home/smart_image.dart';
import 'package:sona/entity/hotel/hotel.dart';
import 'package:sona/entity/kamar/kamar.dart';

class BookingDetailCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final hotelJson = booking['kamar']?['hotel'];
    final Hotel? hotel = hotelJson != null ? Hotel.fromJson(hotelJson) : null;
    final kamarJson = booking['kamar'];
    final Kamar? kamar = kamarJson != null ? Kamar.fromJson(kamarJson) : null;

    final String namaHotel = hotel?.nama ?? 'Unknown Hotel';
    final String imageUrl = hotel?.imagePath ?? 'images/hotel_paradise_resort.jpg';
    final String alamatHotel = hotel?.alamat ?? 'Unknown Address';
    final String roomName = kamar?.tipeKamar ?? kamar?.namaKamar ?? 'Standard Room';
    final String guestCount = '${booking['jumlah_pengunjung'] ?? 1} People';

    final DateTime checkInDate = DateTime.tryParse(booking['check_in'] ?? '') ?? DateTime.now();
    final DateTime checkOutDate = DateTime.tryParse(booking['check_out'] ?? '') ?? DateTime.now();

    final String formattedCheckIn = DateFormat('MMM dd', 'en_US').format(checkInDate);
    final String formattedCheckOut = DateFormat('MMM dd', 'en_US').format(checkOutDate);

    final int days = checkOutDate.difference(checkInDate).inDays;
    final String dateRange = '$formattedCheckIn - $formattedCheckOut, ${checkOutDate.year} • $days ${days > 1 ? 'days' : 'day'}';

    final facilities = kamar?.daftarFasilitas ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: SmartImage(
                    path: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Bookings',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      namaHotel,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateRange,
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppTheme.textGrey,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            alamatHotel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              color: AppTheme.textGrey,
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
          const SizedBox(height: 16),
          // Detail Booking Section
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.25),
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  color: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'Detail Booking',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room
                      _buildDetailRow(
                        label: 'Room',
                        value: roomName,
                      ),
                      const SizedBox(height: 8),
                      // Guest
                      _buildDetailRow(
                        label: 'Guest',
                        value: guestCount,
                      ),
                      const SizedBox(height: 8),
                      // Facility
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(
                              'Facility',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: AppTheme.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Text(
                            ' :  ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGrey,
                            ),
                          ),
                          Expanded(
                            child: facilities.isEmpty
                                ? Text(
                                    '-',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      color: AppTheme.textDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: facilities.map((facility) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F3F4),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          facility.nama,
                                          style: GoogleFonts.roboto(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textTealGrey,
                                          ),
                                        ),
                                      );
                                    }).toList(),
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
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(
          ' :  ',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textGrey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
