import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sona/utils/app_theme.dart';

class RoomFilterResult {
  final DateTimeRange dateRange;
  final int guestCount;

  RoomFilterResult({required this.dateRange, required this.guestCount});
}

class RoomFilterDialog extends StatefulWidget {
  final DateTimeRange initialDateRange;
  final int initialGuestCount;

  const RoomFilterDialog({
    super.key,
    required this.initialDateRange,
    required this.initialGuestCount,
  });

  @override
  State<RoomFilterDialog> createState() => _RoomFilterDialogState();
}

class _RoomFilterDialogState extends State<RoomFilterDialog> {
  late DateTimeRange _dateRange;
  late int _guestCount;

  @override
  void initState() {
    super.initState();
    _dateRange = widget.initialDateRange;
    _guestCount = widget.initialGuestCount;
  }

  String _formatDateRange(DateTimeRange range) {
    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: today,
      lastDate: DateTime(2030, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.tealDark,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Change Booking Info',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.textDark,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderGrey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _formatDateRange(_dateRange),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Guests',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: _guestCount > 1
                      ? () {
                          setState(() {
                            _guestCount--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$_guestCount',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _guestCount++;
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              RoomFilterResult(dateRange: _dateRange, guestCount: _guestCount),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.tealDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
