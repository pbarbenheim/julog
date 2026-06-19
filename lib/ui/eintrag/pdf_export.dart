import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../assembly/eintrag_assembly.dart';

Future<Uint8List> generateEintragPdf({required SelectedEintrag eintrag}) {
  final doc = pw.Document();
  final dateFormat = DateFormat.yMd('de');
  final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm', 'de');
  final now = DateTime.now();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('Seite ${context.pageNumber} von ${context.pagesCount}'),
        ],
      ),
      build: (context) => [
        // Header
        pw.Text(
          eintrag.thema ?? '',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text('Kategorie: ${eintrag.kategorie.name}'),
        pw.Text('Beginn: ${dateTimeFormat.format(eintrag.start)}'),
        pw.Text('Ende: ${dateTimeFormat.format(eintrag.end)}'),
        pw.Text('Exportiert am: ${dateFormat.format(now)}'),
        pw.SizedBox(height: 12),

        // Optional body fields
        if (eintrag.ort != null) ...[
          _sectionHeader('Ort'),
          pw.Text(eintrag.ort!),
          pw.SizedBox(height: 8),
        ],
        if (eintrag.raum != null) ...[
          _sectionHeader('Raum'),
          pw.Text(eintrag.raum!),
          pw.SizedBox(height: 8),
        ],
        if (eintrag.dienstverlauf != null) ...[
          _sectionHeader('Dienstverlauf'),
          pw.Text(eintrag.dienstverlauf!),
          pw.SizedBox(height: 8),
        ],
        if (eintrag.besonderheiten != null) ...[
          _sectionHeader('Besonderheiten'),
          pw.Text(eintrag.besonderheiten!),
          pw.SizedBox(height: 8),
        ],

        // Betreuer
        _sectionHeader('Betreuer'),
        if (eintrag.betreuer.isEmpty)
          pw.Text('-')
        else
          ...eintrag.betreuer.map((b) => pw.Text(b.name)),
        pw.SizedBox(height: 8),

        // Anwesende Jugendliche
        _sectionHeader('Anwesende Jugendliche'),
        if (eintrag.anwesendeJugendliche.isEmpty)
          pw.Text('-')
        else
          ...eintrag.anwesendeJugendliche.map((j) => pw.Text(j.name)),
        pw.SizedBox(height: 8),

        // Entschuldigte Jugendliche
        _sectionHeader('Entschuldigte Jugendliche'),
        if (eintrag.entschuldigteJugendliche.isEmpty)
          pw.Text('-')
        else
          ...eintrag.entschuldigteJugendliche.map((j) => pw.Text(j.name)),
        pw.SizedBox(height: 8),

        // Abwesende Jugendliche die nicht entschuldigt waren (omitted when empty)
        if (eintrag.undefinierteJugendliche.isNotEmpty) ...[
          _sectionHeader('Abwesende Jugendliche'),
          ...eintrag.undefinierteJugendliche.map((j) => pw.Text(j.name)),
          pw.SizedBox(height: 8),
        ],

        // Signaturen
        if (eintrag.signatures.isNotEmpty) ...[
          _sectionHeader('Signaturen'),
          ...eintrag.signatures.map(
            (sig) => _signatureBlock(sig, dateTimeFormat),
          ),
        ],
      ],
    ),
  );

  return doc.save();
}

pw.Widget _sectionHeader(String title) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 2),
  child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
);

pw.Widget _signatureBlock(ShowingSignature sig, DateFormat dateTimeFormat) {
  final validityText = sig.isValid ? 'Gültig' : 'Ungültig';
  final base64Value = sig.signature.toString();

  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8, top: 4),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('${sig.identity.name} (${sig.identity.function})'),
        pw.Text('Zeitstempel: ${dateTimeFormat.format(sig.timestamp)}'),
        pw.Text('Gültigkeit: $validityText'),
        pw.Text('Version: ${sig.version}'),
        pw.Text('Signaturwert:', style: const pw.TextStyle(fontSize: 8)),
        pw.Text(
          base64Value,
          style: pw.TextStyle(font: pw.Font.courier(), fontSize: 7),
        ),
      ],
    ),
  );
}
