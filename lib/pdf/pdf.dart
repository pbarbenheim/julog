import 'package:dienstbuch/repository/repository.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

extension EintragPdfGeneration on Eintrag {
  Future<Uint8List> buildPdf(PdfPageFormat format) async {
    final doc = pw.Document();

    doc.addPage(pw.MultiPage(
      header: await DienstbuchPdf.getDocHeader(),
      footer: await DienstbuchPdf.getDocFooter(),
      pageTheme: await DienstbuchPdf.getDocTheme(format),
      build: (context) => [pw.Text("Test")],
    ));

    return doc.save();
  }
}

class DienstbuchPdf {
  static Future<pw.Widget Function(pw.Context)> getDocHeader() async {
    String logo = await rootBundle.loadString("assets/logo.svg");

    return (context) {
      return pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Text(
                  "Auszug aus dem Dienstbuch der\n    JF Darscheid",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 20),
                ),
              ),
              pw.SizedBox(
                height: 70,
                child: pw.SvgImage(svg: logo),
              ),
            ],
          ),
          if (context.pageNumber > 1) pw.SizedBox(height: 20),
        ],
      );
    };
  }

  static Future<pw.Widget Function(pw.Context)> getDocFooter() async {
    return (context) => pw.Text("Footer");
  }

  static Future<pw.PageTheme> getDocTheme(PdfPageFormat format) async {
    final base = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();
    final italic = await PdfGoogleFonts.notoSansItalic();
    return pw.PageTheme(
      pageFormat: format,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),
    );
  }
}
