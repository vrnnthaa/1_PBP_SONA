import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableReviewText extends StatefulWidget {
  final String text;
  final int maxLength;
  final Color textColor;
  final Color actionColor;
  final double fontSize;

  const ExpandableReviewText({
    super.key,
    required this.text,
    this.maxLength = 180,
    required this.textColor,
    required this.actionColor,
    this.fontSize = 12,
  });

  @override
  State<ExpandableReviewText> createState() => _ExpandableReviewTextState();
}

class _ExpandableReviewTextState extends State<ExpandableReviewText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cleanText = widget.text.trim();
    final shouldTrim = cleanText.length > widget.maxLength;

    final displayText = shouldTrim && !isExpanded
        ? '${cleanText.substring(0, widget.maxLength)}...'
        : cleanText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText.isEmpty ? '-' : displayText,
          style: GoogleFonts.montserrat(
            fontSize: widget.fontSize,
            height: 1.45,
            color: widget.textColor,
          ),
        ),
        if (shouldTrim)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  isExpanded ? 'Read Less' : 'Read More',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.actionColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
