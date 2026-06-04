import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sona/api/kamar/api_kamar.dart';
import 'package:sona/entity/kamar/kamar_availability.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/kamar/kamar_card.dart';
import 'package:sona/widgets/kamar/kamar_filter_dialog.dart';
import 'package:sona/pages/pemesanan/pemesanan_page.dart';

class HotelRoomListPage extends StatefulWidget {
  final int idHotel;
  final String hotelName;

  const HotelRoomListPage({
    super.key,
    required this.idHotel,
    required this.hotelName,
  });

  @override
  State<HotelRoomListPage> createState() => _HotelRoomListPageState();
}

class _HotelRoomListPageState extends State<HotelRoomListPage> {
  final ApiKamar _apiKamar = ApiKamar();

  late DateTimeRange _selectedDateRange;
  int _guestCount = 2;

  bool _isLoading = true;
  List<KamarAvailability> _rooms = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _selectedDateRange = DateTimeRange(
      start: today.add(const Duration(days: 1)),
      end: today.add(const Duration(days: 3)),
    );

    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiKamar.fetchAvailableRooms(
        idHotel: widget.idHotel,
        checkIn: _selectedDateRange.start,
        checkOut: _selectedDateRange.end,
        guest: _guestCount,
      );

      if (!mounted) return;

      setState(() {
        _rooms = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildHeaderSubtitle() {
    final formatter = DateFormat('dd MMM');
    return '${formatter.format(_selectedDateRange.start)} - ${formatter.format(_selectedDateRange.end)}, $_guestCount guests';
  }

  Future<void> _openFilterDialog() async {
    final result = await showDialog<RoomFilterResult>(
      context: context,
      builder: (_) => RoomFilterDialog(
        initialDateRange: _selectedDateRange,
        initialGuestCount: _guestCount,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDateRange = result.dateRange;
        _guestCount = result.guestCount;
      });

      await _fetchRooms();
    }
  }

  void _onSelectRoom(KamarAvailability room) {
    
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PemesananPage(
          idKamar: room.idKamar,
          idUser: 1, // TODO: Ganti dengan user ID yang sebenarnya
          namaKamar: room.namaKamar,
          namaHotel: widget.hotelName,
          hargaPerMalam: room.harga,
          selectedDateRange: _selectedDateRange,
          jumlahPengunjung: _guestCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F2),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EFEF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.hotelName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _buildHeaderSubtitle(),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _openFilterDialog,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EFEF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _rooms.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _fetchRooms,
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'Tidak ada kamar tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchRooms,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: _rooms.length,
                        itemBuilder: (context, index) {
                          final room = _rooms[index];
                          return RoomListCard(
                            room: room,
                            onSelectRoom: room.statusAvailable
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
