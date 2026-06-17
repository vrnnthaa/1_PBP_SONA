import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sona/utils/app_theme.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String bookingId;
  final String hotelName;
  final String roomName; 
  final String userName;
  final String userPhone; 
  final String userEmail; 
  final double amountPaid;
  final String paymentMethod; 
  final String transactionId; 
  final DateTime transactionDate;

  const PaymentSuccessPage({
    super.key,
    required this.bookingId,
    required this.hotelName,
    required this.roomName,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.amountPaid,
    required this.paymentMethod,
    required this.transactionId,
    required this.transactionDate,
  });

  // ========================================================
  // FUNGSI AJAIB UNTUK MEMBUAT PDF SESUAI DESAIN MOCKUP
  // ========================================================
  Future<void> _generateAndDownloadPdf(BuildContext context, String formattedPrice, String formattedDate, String formattedTime) async {
    final pdf = pw.Document();

    // Palet warna sesuai desain Mockup PDF
    final darkTeal = PdfColor.fromHex('#0B4F54');
    final lightTeal = PdfColor.fromHex('#4B8285');
    final tableHeaderBg = PdfColor.fromHex('#AEC8C5');

    final ByteData imageBytes = await rootBundle.load('assets/images/Sona Eyes Pict.jpg');
    final Uint8List imageUint8List = imageBytes.buffer.asUint8List();
    final logoImage = pw.MemoryImage(imageUint8List);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              //HEADER (LOGO & BRAND) ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                      pw.Image(
                        logoImage,
                        width : 45,
                        height: 45,
                        fit: pw.BoxFit.contain,
                      ),

                      pw.Spacer(),

                      pw.Text('SONA', style: pw.TextStyle(color: darkTeal, fontSize: 24, letterSpacing: 1.5)),
                    ],
              ),
              pw.SizedBox(height: 10),
              
              //TITLE ---
              pw.Text('PAYMENT RECEIPT', style: pw.TextStyle(color: darkTeal, fontSize: 26, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
              pw.SizedBox(height: 5),
              pw.Divider(color: darkTeal, thickness: 1.5),
              pw.SizedBox(height: 12),

              //BOOKING CODE & DATE ---
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Booking Code', style: pw.TextStyle(color: lightTeal, fontSize: 11)),
                        pw.SizedBox(height: 2),
                        pw.Text(bookingId, style: pw.TextStyle(color: darkTeal, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Date', style: pw.TextStyle(color: lightTeal, fontSize: 11)),
                        pw.SizedBox(height: 2),
                        pw.Text(formattedDate, style: pw.TextStyle(color: darkTeal, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              //BILLED TO SECTION ---
              pw.Text('Billed to', style: pw.TextStyle(color: lightTeal, fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildPdfRow('Name :', userName, darkTeal),
              _buildPdfRow('Contact :', userPhone, darkTeal),
              _buildPdfRow('Email :', userEmail, darkTeal),
              
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey400, thickness: 1),
              pw.SizedBox(height: 16),

              //PAYMENT SUMMARY SECTION ---
              pw.Text('Payment Summary', style: pw.TextStyle(color: lightTeal, fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildPdfRow('Total Paid :', formattedPrice, darkTeal),
              _buildPdfRow('Payment Method :', paymentMethod, darkTeal),
              _buildPdfRow('Transaction ID :', transactionId, darkTeal),
              pw.SizedBox(height: 20),

              // DESCRIPTION TABLE ---
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: darkTeal, width: 1),
                headerStyle: pw.TextStyle(color: darkTeal, fontSize: 11, fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: tableHeaderBg),
                cellStyle: const pw.TextStyle(color: PdfColors.black, fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                data: [
                  ['Description', 'Amount'],
                  ['$roomName, $hotelName', formattedPrice],
                ],
              ),
              pw.SizedBox(height: 30),

              //FOOTER (QR CODE & SIGNATURE) ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400, width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: bookingId,
                          width: 80,
                          height: 80,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('SCAN AT RECEPTION', style: pw.TextStyle(color: darkTeal, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Authorized by:', style: const pw.TextStyle(color: PdfColors.black, fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text('Dilan Parengkhuan', style: pw.TextStyle(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Share / Save PDF Dialog
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'SONA_Receipt_$bookingId.pdf',
    );
  }

  pw.Widget _buildPdfRow(String label, String value, PdfColor darkTeal) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120, 
            child: pw.Text(label, style: pw.TextStyle(color: darkTeal, fontSize: 11, fontWeight: pw.FontWeight.bold))
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(color: PdfColors.black, fontSize: 11))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedPrice = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
    ).format(amountPaid);

    final String formattedDate = DateFormat('d MMMM yyyy', 'en_US').format(transactionDate);
    final String formattedTime = DateFormat('HH:mm').format(transactionDate);

    return WillPopScope(
      onWillPop: () async {
        Navigator.popUntil(context, (route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
          title: Text(
            'Verify to Pay',
            style: GoogleFonts.montserrat(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 70, height: 70,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text('Payment Successful!', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 8),
              Text(
                'Your booking has been confirmed. A receipt\nhas been sent to your email',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(fontSize: 13, color: AppTheme.textTealGrey, height: 1.4),
              ),
              const SizedBox(height: 32),
              Text('Scan to Check-In', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: QrImageView(data: bookingId, version: QrVersions.auto, size: 140.0),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HOTEL NAME', style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(hotelName, style: GoogleFonts.montserrat(fontSize: 16, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppTheme.borderLight, height: 1, thickness: 1),
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildReceiptItem('BOOKING ID', bookingId)),
                        Expanded(child: _buildReceiptItem('NAME', userName)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildReceiptItem('TIME', formattedTime)),
                        Expanded(child: _buildReceiptItem('DATE', formattedDate)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('AMOUNT PAID', style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
                          Text(formattedPrice, style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // PANGGIL FUNGSI PEMBUAT PDF DI SINI
                    _generateAndDownloadPdf(context, formattedPrice, formattedDate, formattedTime);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Download Receipt as PDF', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Text('Back to Home', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.montserrat(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.bold)),
      ],
    );
  }
}