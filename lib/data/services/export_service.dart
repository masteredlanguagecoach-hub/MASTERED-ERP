import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

class ExportService {
  /// Export tabular data to CSV formatted string
  static String exportToCsv(List<String> headers, List<List<dynamic>> rows) {
    final buffer = StringBuffer();
    buffer.writeln(headers.map((h) => '"$h"').join(','));

    for (final row in rows) {
      final line = row.map((cell) {
        final str = (cell ?? '').toString().replaceAll('"', '""');
        return '"$str"';
      }).join(',');
      buffer.writeln(line);
    }
    return buffer.toString();
  }

  /// Print or Save PDF Report
  static Future<void> exportReportPdf({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => pw.Column(
          cross: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('MASTERED ERP - $title', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
            pw.SizedBox(height: 4),
            pw.Text('Generated on: ${DateTime.now().toString().substring(0, 16)}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.red800),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellPadding: const pw.EdgeInsets.all(5),
          ),
        ],
      ),
    );

    final Uint8List pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: '${title.replaceAll(' ', '_')}.pdf',
    );
  }
}
