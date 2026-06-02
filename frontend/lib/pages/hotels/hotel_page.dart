import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class HotelPage extends StatelessWidget {
  final String? location;
  final String? dateRange;
  final String? guests;

  const HotelPage({
    super.key,
    this.location,
    this.dateRange,
    this.guests,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          'Hotels Search Results',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  size: 80,
                  color: AppTheme.accentTeal,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hotel Page Placeholder',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This page will contain hotel lists and search details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 14,
                ),
              ),
              if (location != null || dateRange != null || guests != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Search Parameters:',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Divider(height: 20),
                      _buildSearchParamRow(Icons.location_on_rounded, 'Location', location ?? '-'),
                      const SizedBox(height: 10),
                      _buildSearchParamRow(Icons.calendar_month_rounded, 'Dates', dateRange ?? '-'),
                      const SizedBox(height: 10),
                      _buildSearchParamRow(Icons.people_rounded, 'Guests', guests ?? '-'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchParamRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.accentTeal),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
