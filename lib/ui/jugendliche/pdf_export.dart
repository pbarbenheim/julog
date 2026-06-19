import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../repository/model/jugendliche/jugendlicher.dart';

Future<Uint8List> generateJugendlichePdf({
  required String title,
  required DateTime exportDate,
  required List<Jugendlicher> jugendliche,
  required List<String> selectedFields,
}) {
  final doc = pw.Document();
  final dateFormat = DateFormat.yMd('de');

  final headers = selectedFields;
  final rows = jugendliche
      .map(
        (j) => selectedFields
            .map(
              (field) => switch (field) {
                'Name' => j.name,
                'Passnummer' => j.pass ?? '',
                'Geburtsdatum' => dateFormat.format(j.birthDate),
                'Geschlecht' => j.gender.display,
                'Mitglied seit' => dateFormat.format(j.memberSince),
                'Austrittsdatum' =>
                  j.exitDate != null ? dateFormat.format(j.exitDate!) : '',
                'Austrittsgrund' => j.exitReason?.display ?? '',
                'Unterschrift' => '',
                _ => '',
              },
            )
            .toList(),
      )
      .toList();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          pw.Text('Exportiert am: ${dateFormat.format(exportDate)}'),
          pw.SizedBox(height: 8),
        ],
      ),
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('Seite ${context.pageNumber} von ${context.pagesCount}'),
        ],
      ),
      build: (context) => [
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: headers
                  .map(
                    (h) => pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        h,
                        style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
            ),
            ...rows.map(
              (row) => pw.TableRow(
                children: row
                    .map(
                      (cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(cell),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  return doc.save();
}
