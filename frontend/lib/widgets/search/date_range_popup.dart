import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class DateRangePopup extends StatefulWidget {
  final DateTimeRange? initialRange;

  const DateRangePopup({super.key, this.initialRange});

  @override
  State<DateRangePopup> createState() => _DateRangePopupState();
}

class _DateRangePopupState extends State<DateRangePopup> {
  late List<DateTime?> _values;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _values = widget.initialRange != null
        ? [widget.initialRange!.start, widget.initialRange!.end]
        : [];
  }

  @override
  Widget build(BuildContext context) {
    final firstAllowedDate = _today;
    final initialMonth =
        widget.initialRange?.start.isAfter(firstAllowedDate) == true
        ? widget.initialRange!.start
        : firstAllowedDate;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 330,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.range,
                firstDate: firstAllowedDate,
                lastDate: DateTime(2030, 12, 31),
                currentDate: initialMonth,
                selectedDayHighlightColor: AppTheme.tealDark,
                centerAlignModePicker: true,
                weekdayLabels: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
                controlsTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
                dayTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                disabledDayTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFBFC7C9),
                  fontWeight: FontWeight.w500,
                ),
                selectedDayTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                yearTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                daySplashColor: Colors.transparent,
                lastMonthIcon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppTheme.textDark,
                ),
                nextMonthIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textDark,
                ),
                dayBorderRadius: BorderRadius.circular(999),
              ),
              value: _values,
              onValueChanged: (dates) {
                setState(() {
                  _values = dates;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFE9EFEF),
                        foregroundColor: AppTheme.textDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed:
                          _values.length >= 2 &&
                              _values[0] != null &&
                              _values[1] != null
                          ? () {
                              Navigator.pop(
                                context,
                                DateTimeRange(
                                  start: _values[0]!,
                                  end: _values[1]!,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppTheme.tealDark,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.tealDark.withOpacity(
                          0.35,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
