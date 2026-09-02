import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../models/payment_model.dart';
import '../models/student_model.dart';

class PdfReceiptService {
  static Future<Uint8List> generateReceiptPdf({
    required PaymentModel payment,
    required StudentModel student,
  }) async {
    final pdf = pw.Document();

    // Load logo if available
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load(AppConstants.logoPath);
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            cross: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              pw.Row(
                main: pw.MainAxisAlignment.spaceBetween,
                cross: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 48,
                          height: 48,
                          margin: const pw.EdgeInsets.only(right: 12),
                          child: pw.Image(logoImage),
                        ),
                      pw.Column(
                        cross: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            AppConstants.academyName,
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red800,
                            ),
                          ),
                          pw.Text(
                            'ACADEMY MANAGEMENT SYSTEM',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    cross: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FEE RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Receipt No: ${payment.receiptNo}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red800,
                        ),
                      ),
                      pw.Text(
                        'Date: ${DateFormatter.formatDisplay(payment.date)}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey400, thickness: 1),
              pw.SizedBox(height: 16),

              // Student Info Box
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  main: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      cross: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Student Name: ${student.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text('Admission No: ${student.admissionNo}', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('Phone: ${student.phone}', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      cross: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Course: ${student.course}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text('Student ID: ${student.studentId}', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('Payment Mode: ${payment.paymentMode}', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Payment Ledger Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Payment Mode', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Amount Paid', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(payment.remarks.isNotEmpty ? payment.remarks : 'Course Fee Payment', style: const pw.TextStyle(fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(payment.paymentMode, style: const pw.TextStyle(fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(CurrencyFormatter.format(payment.amount), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Summary Ledger
              pw.Row(
                main: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    child: pw.Column(
                      children: [
                        _buildSummaryRow('Total Course Fee:', CurrencyFormatter.format(student.totalFee)),
                        pw.SizedBox(height: 4),
                        _buildSummaryRow('Amount Received Today:', CurrencyFormatter.format(payment.amount), isBold: true),
                        pw.SizedBox(height: 4),
                        _buildSummaryRow('Total Paid to Date:', CurrencyFormatter.format(student.paidFee)),
                        pw.Divider(color: PdfColors.grey300),
                        _buildSummaryRow('Remaining Balance:', CurrencyFormatter.format(student.balanceFee), isBold: true, isHighlight: true),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Signatures & Stamp Section
              pw.Row(
                main: pw.MainAxisAlignment.spaceBetween,
                cross: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    cross: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Terms & Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      pw.Text('1. Fees once paid are non-refundable.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('2. Keep this receipt safe for future reference.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 140,
                        height: 40,
                        alignment: pw.Alignment.bottomCenter,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey800, width: 1)),
                        ),
                        child: pw.Text('Authorized Officer', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('${AppConstants.academyName} Accounts', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Thank you for choosing ${AppConstants.academyName}! Generated by MASTERED ERP System.',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return pw.Row(
      main: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHighlight ? PdfColors.red800 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static Future<void> printOrDownloadReceipt({
    required PaymentModel payment,
    required StudentModel student,
  }) async {
    final pdfBytes = await generateReceiptPdf(payment: payment, student: student);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Receipt_${payment.receiptNo}.pdf',
    );
  }
}
