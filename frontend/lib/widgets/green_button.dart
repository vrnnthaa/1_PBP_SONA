import 'package:flutter/material.dart';

class GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  const GreenButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45, 

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,

          colors: [
            Color(0xFF003A3F),
            Color(0xFF00727C),
          ],
        ),

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 4),
            
          ),
        ]
      ),

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,

          shadowColor: Colors.transparent,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
