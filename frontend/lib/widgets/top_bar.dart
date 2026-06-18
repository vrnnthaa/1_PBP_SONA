import 'package:flutter/material.dart';
import 'package:sona/utils/app_theme.dart';

class TopBar extends StatelessWidget {
  final String title;
  
  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 80,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      
        decoration: BoxDecoration(
          color: Color(0xFFF6F7F9),
      
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepTeal.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: AppTheme.accentTeal),
            ),
      
            Text(
              title,
              
              style: AppTheme.titleStyle,
            ),
          ],
        ),
      ),
    );
  }
}