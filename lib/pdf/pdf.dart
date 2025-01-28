import 'package:flutter/services.dart';
import 'package:julog/repository/eintrag/eintrag.dart';
import 'package:julog/repository/util/util.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../pubspec.g.dart';

extension EintragPdfGeneration on Eintrag {
  Future<Uint8List> buildPdf(PdfPageFormat format) async {
    final doc = pw.Document();

    doc.addPage(pw.MultiPage(
      header: await JulogPdf.getDocHeader(),
      footer: await JulogPdf.getDocFooter(),
      pageTheme: await JulogPdf.getDocTheme(format),
      build: (context) => [
        pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
        pw.Text("Eintrag #$id"),
        pw.Text("Beginn: ${beginn.toString()}"),
        pw.Text("Ende: ${ende.toString()}"),
        pw.Text("Kategorie: #${kategorie.id} ${kategorie.name}"),
        pw.Text("Thema: $thema"),
        pw.Text("Ort: $ort"),
        pw.Text("Raum: $raum"),
        pw.Text("Dienstverlauf: $dienstverlauf"),
        pw.Text("Besonderheiten: $besonderheiten"),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
        pw.Text("Betreuer:"),
        ...(betreuer.map((e) => pw.Text("\t\t\t\t- #${e.id} ${e.name}"))),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 20)),
        pw.Text("Jugendliche:"),
        ...(jugendliche.map((e) => pw.Text(
            "\t\t\t\t- #${e.jugendlicher.id} ${e.jugendlicher.name} \t\t(${e.anwesenheit})"))),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 40)),
        ...(signaturen.map((e) {
          final userc = Util.userIdToComponents(e.identity.userId);
          String name = userc.$1;
          if (userc.$2.isNotEmpty) {
            name = "$name, ${userc.$2}";
          }
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Text("am ${e.signedAt.toString()},\n\t\t\tgez. $name"),
          );
        }))
      ],
    ));

    return doc.save();
  }
}

class JulogPdf {
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
                  "Auszug aus dem Dienstbuch",
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
    final now = DateTime.now().toString();
    return (context) =>
        pw.Text("Auszug generiert am $now von Julog v${Pubspec.versionSmall}");
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
