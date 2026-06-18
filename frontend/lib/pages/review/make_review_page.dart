import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:sona/widgets/review/booking_detail_card.dart';
import 'package:sona/widgets/review/star_rating_selector.dart';
import 'package:sona/api/review/api_review.dart';
import 'package:sona/providers/auth/token_provider.dart';
import 'package:sona/providers/auth/profile_provider.dart';
import 'package:sona/providers/booking/bookings_provider.dart';
import 'package:sona/services/make_review.dart';
import 'package:sona/widgets/utils/alert_love.dart';

class MakeReviewPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> booking;

  const MakeReviewPage({super.key, required this.booking});

  @override
  ConsumerState<MakeReviewPage> createState() => _MakeReviewPageState();
}

class _MakeReviewPageState extends ConsumerState<MakeReviewPage> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;
  String? _photoPath;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppTheme.deepTeal, size: 24),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepTeal, fontSize: 15),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                    maxWidth: 600,
                    maxHeight: 600,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _photoPath = pickedFile.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.deepTeal, size: 24),
                title: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.deepTeal, fontSize: 15),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                    maxWidth: 600,
                    maxHeight: 600,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _photoPath = pickedFile.path;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();

    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating by tapping a star.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (comment.isEmpty || comment.length < 20) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final token = ref.read(tokenProvider);
      final profileAsync = ref.read(profileProvider);
      final profile = profileAsync.valueOrNull;

      if (token == null || token.isEmpty || profile == null) {
        throw Exception('User is not authenticated');
      }

      final idUser = profile['id_user'] ?? 1;
      final idPemesanan = int.tryParse(widget.booking['id_pemesanan'].toString()) ?? 0;
      final username = profile['nama'] ?? ''; 

      String? finalPhotoUrl;
      if (_photoPath != null && _photoPath!.isNotEmpty) {
        finalPhotoUrl = await UploadReviewFotoService().uploadFotoReview(File(_photoPath!));
        if (finalPhotoUrl == null) {
          throw Exception('Failed to upload review image to Supabase');
        }
      }

      await ApiReview().createReview(
        idUser: idUser,
        idPemesanan: idPemesanan,
        komentar: comment,
        rating: _rating,
        photoUrl: finalPhotoUrl,
        token: token,
      );

      // Invalidate bookingsProvider to refresh the history screen
      ref.invalidate(bookingsProvider);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success pop up
        await AlertLove.show(
          context: context,
          title: 'Successfully Submitted!',
          subtitle: 'Thank you for sharing your experience,$username! Your feedback helps others make better travel choices',
        );

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final comment = _commentController.text;
    final isFieldEmpty = comment.isEmpty;
    final isTooShort = comment.length < 20;
    
    String? errorText;
    if (_hasError) {
      if (isFieldEmpty) {
        errorText = 'The review must not be left blank';
      } else if (isTooShort) {
        errorText = 'The review must be at least 20 characters';
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Write A Review',
          style: GoogleFonts.montserrat(
            color: AppTheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.borderGrey,
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookingDetailCard(booking: widget.booking),
                const SizedBox(height: 16),
                StarRatingSelector(
                  rating: _rating,
                  onRatingChanged: (val) {
                    setState(() {
                      _rating = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Add photos',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CustomPaint(
                        painter: DashedRectPainter(
                          color: AppTheme.textGrey.withOpacity(0.6),
                          strokeWidth: 1.2,
                          gap: 4.0,
                          borderRadius: 12.0,
                        ),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add,
                                color: AppTheme.textGrey,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  color: AppTheme.textGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_photoPath != null) ...[
                      const SizedBox(width: 12),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.file(
                                File(_photoPath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _photoPath = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppTheme.errorRed,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Write your review',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  onChanged: (text) {
                    if (_hasError) {
                      setState(() {
                        _hasError = false;
                      });
                    }
                  },
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: AppTheme.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What did you like or dislike? How was the service, the food, or the room?',
                    hintStyle: GoogleFonts.roboto(
                      color: AppTheme.textGrey.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _hasError ? AppTheme.errorRed : Colors.black.withOpacity(0.08),
                        width: _hasError ? 1.2 : 0.8,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _hasError ? AppTheme.errorRed : AppTheme.primary,
                        width: 1.2,
                      ),
                    ),
                    errorText: errorText,
                    errorStyle: GoogleFonts.roboto(
                      color: AppTheme.errorRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Minimum 20 characters',
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: AppTheme.textGrey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.24),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Submit Review',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  DashedRectPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = Path();

    double distance = 0.0;
    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashedPath.addPath(
          measurePath.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
