import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sona/api/kamar/api_kamar.dart';
import 'package:sona/entity/kamar/kamar_availability.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/kamar/kamar_card.dart';
import 'package:sona/widgets/loading_animation.dart';
import 'package:sona/widgets/search/date_range_popup.dart';
import 'package:sona/pages/kamar/kamar_detail.dart';

const Color bgColor = Color(0xFFF3F4F4);
const Color primaryColor = Color(0xFF003A3F);
const Color secondaryText = Color(0xFF61797B);
const Color pillInnerColor = Color(0xFFDDE3E3);

class KamarPage extends StatefulWidget {
  final int idHotel;
  final String hotelName;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final int guests;

  const KamarPage({
    super.key,
    required this.idHotel,
    required this.hotelName,
    this.checkInDate,
    this.checkOutDate,
    this.guests = 1,
  });

  @override
  State<KamarPage> createState() => _KamarPageState();
}

class _KamarPageState extends State<KamarPage> {
  final ApiKamar _apiKamar = ApiKamar();

  late DateTimeRange _selectedDateRange;
  late int _guestCount;

  bool _isLoading = true;
  String? _errorMessage;
  List<KamarAvailability> _rooms = [];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final incomingCheckIn = widget.checkInDate;
    final incomingCheckOut = widget.checkOutDate;

    final DateTime initialStart = incomingCheckIn != null
        ? DateTime(
            incomingCheckIn.year,
            incomingCheckIn.month,
            incomingCheckIn.day,
          )
        : today.add(const Duration(days: 1));

    final DateTime initialEnd =
        incomingCheckOut != null && incomingCheckOut.isAfter(initialStart)
        ? DateTime(
            incomingCheckOut.year,
            incomingCheckOut.month,
            incomingCheckOut.day,
          )
        : initialStart.add(const Duration(days: 1));

    _selectedDateRange = DateTimeRange(start: initialStart, end: initialEnd);
    _guestCount = widget.guests > 0 ? widget.guests : 1;

    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await _apiKamar.fetchAvailableRooms(
        idHotel: widget.idHotel,
        checkIn: _selectedDateRange.start,
        checkOut: _selectedDateRange.end,
        guest: _guestCount,
      );

      final sortedRooms = List<KamarAvailability>.from(result)
        ..sort((a, b) {
          if (a.statusAvailable != b.statusAvailable) {
            return a.statusAvailable ? -1 : 1;
          }
          return a.harga.compareTo(b.harga);
        });

      if (!mounted) return;

      setState(() {
        _rooms = sortedRooms;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _rooms = [];
        _errorMessage = 'Gagal memuat kamar. Coba lagi.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.montserrat(fontSize: 12.5),
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatHeaderDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDialog<DateTimeRange>(
      context: context,
      barrierDismissible: true,
      builder: (_) => DateRangePopup(initialRange: _selectedDateRange),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      await _fetchRooms();
    }
  }

  void _showGuestsPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5DCDD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Select Number of Guests',
                  style: GoogleFonts.montserrat(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final guestCount = index + 1;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: const Icon(
                        Icons.people_alt_outlined,
                        color: AppTheme.accentTeal,
                      ),
                      title: Text(
                        '$guestCount Guest${guestCount > 1 ? 's' : ''}',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.primary,
                        ),
                      ),
                      trailing: _guestCount == guestCount
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.tealDark,
                            )
                          : null,
                      onTap: () async {
                        setState(() {
                          _guestCount = guestCount;
                        });
                        Navigator.pop(context);
                        await _fetchRooms();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditBookingOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5DCDD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Ubah Pencarian',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pilih bagian yang ingin diubah',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: secondaryText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18),
                _BookingOptionTile(
                  icon: Icons.date_range_rounded,
                  title: 'Ubah tanggal',
                  subtitle:
                      '${_formatHeaderDate(_selectedDateRange.start)} - ${_formatHeaderDate(_selectedDateRange.end)}',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await Future.delayed(const Duration(milliseconds: 180));
                    await _showDateRangePicker();
                  },
                ),
                const SizedBox(height: 10),
                _BookingOptionTile(
                  icon: Icons.people_alt_outlined,
                  title: 'Ubah tamu',
                  subtitle: '$_guestCount guest${_guestCount > 1 ? 's' : ''}',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await Future.delayed(const Duration(milliseconds: 180));
                    _showGuestsPicker();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSelectRoom(KamarAvailability room) {
    if (room.detailKamar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Detail kamar belum tersedia.',
            style: GoogleFonts.montserrat(fontSize: 12.5),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomDetailPage(
          room: room,
          checkInDate: _selectedDateRange.start,
          checkOutDate: _selectedDateRange.end,
          guests: _guestCount,
          hotelName: widget.hotelName,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 22,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: primaryColor,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Select Room',
                    style: GoogleFonts.montserrat(
                      color: primaryColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showEditBookingOptions,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: pillInnerColor,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hotelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _HeaderActionItem(
                            icon: Icons.date_range_rounded,
                            label:
                                '${_formatHeaderDate(_selectedDateRange.start)} - ${_formatHeaderDate(_selectedDateRange.end)}',
                            onTap: _showDateRangePicker,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeaderActionItem(
                            icon: Icons.people_alt_outlined,
                            label:
                                '$_guestCount guest${_guestCount > 1 ? 's' : ''}',
                            onTap: _showGuestsPicker,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _fetchRooms,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          const Icon(
            Icons.hotel_class_outlined,
            size: 58,
            color: Color(0xFF8CA0A3),
          ),
          const SizedBox(height: 14),
          Text(
            'Tidak ada kamar ditemukan',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah tanggal atau jumlah tamu',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: _fetchRooms,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          const Icon(
            Icons.cloud_off_rounded,
            size: 58,
            color: Color(0xFF8CA0A3),
          ),
          const SizedBox(height: 14),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tarik ke bawah untuk mencoba lagi',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingAnimation())
                  : _errorMessage != null
                  ? _buildErrorState()
                  : _rooms.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchRooms,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        itemCount: _rooms.length,
                        itemBuilder: (context, index) {
                          final room = _rooms[index];
                          return KamarCard(
                            room: room,
                            onSelectRoom:
                                room.statusAvailable && room.detailKamar != null
                                ? () => _onSelectRoom(room)
                                : null,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: secondaryText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BookingOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F7F7),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE9E7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF89A0A2),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
