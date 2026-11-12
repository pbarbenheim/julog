import 'dart:convert';
import 'dart:typed_data';

import '../repository/model/model.dart';
import 'jahresbericht.dart';
import 'manuelle_angaben.dart';
import 'vollstaendigkeit.dart';

/// Wird geworfen, wenn ein unvollständiger Jahresbericht exportiert werden
/// soll. [vollstaendigkeit] sagt, was fehlt.
class UnvollstaendigerBerichtException implements Exception {
  final Vollstaendigkeit vollstaendigkeit;

  UnvollstaendigerBerichtException(this.vollstaendigkeit);

  @override
  String toString() =>
      'UnvollstaendigerBerichtException: Der Jahresbericht ist nicht '
      'vollständig. $vollstaendigkeit';
}

/// Erzeugt das XML-Dokument des Jahresberichts für [berichtsjahr].
///
/// Berechnet den [Berichtswert] aus den Domänendaten (siehe
/// [berechneBerichtswert]) und ergänzt ihn um die manuellen [angaben] und
/// `Organisationen` (immer 1). Format: Wurzelelement `<xml>` mit einem
/// `<field key="…">n</field>` je Feld, siehe `docs/jahresbericht-felder.md`.
/// Schlüssel enthalten Umlaute als echte Zeichen; das Dokument ist für
/// UTF-8 gedacht (siehe [erzeugeJahresberichtXmlBytes]).
///
/// Der Export ist nur bei vollständigen Angaben möglich (siehe
/// [pruefeVollstaendigkeit]); sonst wirft die Funktion eine
/// [UnvollstaendigerBerichtException]. Wer vorher wissen will, was fehlt,
/// ruft [pruefeVollstaendigkeit] selbst auf.
String erzeugeJahresberichtXml({
  required int berichtsjahr,
  required List<Jugendlicher> jugendliche,
  required List<Betreuer> betreuer,
  required List<Eintrag> eintraege,
  required List<Kategorie> kategorien,
  required ManuelleAngaben angaben,
  Ueberschreibungen ueberschreibungen = const Ueberschreibungen.keine(),
}) {
  final vollstaendigkeit = pruefeVollstaendigkeit(
    berichtsjahr: berichtsjahr,
    angaben: angaben,
    kategorien: kategorien,
    eintraege: eintraege,
  );
  if (!vollstaendigkeit.istVollstaendig) {
    throw UnvollstaendigerBerichtException(vollstaendigkeit);
  }

  final berechnet = berechneBerichtswert(
    berichtsjahr: berichtsjahr,
    jugendliche: jugendliche,
    betreuer: betreuer,
    eintraege: eintraege,
    kategorien: kategorien,
    ueberschreibungen: ueberschreibungen,
  ).felder;

  final felder = <String, int>{'Organisationen': 1};
  for (final e in berechnet.entries) {
    if (!e.key.startsWith('Arbeit_Wert_')) felder[e.key] = e.value;
  }
  felder['Alter_Anz_EA_bis_27_M'] = angaben.einsatzabteilungM!;
  felder['Alter_Anz_EA_bis_27_W'] = angaben.einsatzabteilungW!;
  felder['Alter_Anz_EA_bis_27_D'] = angaben.einsatzabteilungD!;
  for (var n = 1; n <= anzahlFragen; n++) {
    final nn = n.toString().padLeft(2, '0');
    final ja = angaben.frage(n)!;
    felder['Frage_${nn}_MML_JA'] = ja ? 1 : 0;
    felder['Frage_${nn}_MML_NEIN'] = ja ? 0 : 1;
  }
  final arbeit = {
    ...berechnet,
    'Arbeit_Wert_11': angaben.arbeitWert11!,
    'Arbeit_Wert_20': angaben.arbeitWert20!,
  };
  for (final key in _arbeitswertFelder) {
    felder[key] = arbeit[key]!;
  }

  final buffer = StringBuffer('<?xml version="1.0" encoding="UTF-8"?>\n<xml>');
  for (final e in felder.entries) {
    buffer.write('<field key="${_escape(e.key)}">${e.value}</field>');
  }
  buffer.write('</xml>\n');
  return buffer.toString();
}

/// Wie [erzeugeJahresberichtXml], aber als UTF-8-kodierte Bytes, so wie sie
/// in die Datei geschrieben werden.
Uint8List erzeugeJahresberichtXmlBytes({
  required int berichtsjahr,
  required List<Jugendlicher> jugendliche,
  required List<Betreuer> betreuer,
  required List<Eintrag> eintraege,
  required List<Kategorie> kategorien,
  required ManuelleAngaben angaben,
  Ueberschreibungen ueberschreibungen = const Ueberschreibungen.keine(),
}) => Uint8List.fromList(
  utf8.encode(
    erzeugeJahresberichtXml(
      berichtsjahr: berichtsjahr,
      jugendliche: jugendliche,
      betreuer: betreuer,
      eintraege: eintraege,
      kategorien: kategorien,
      angaben: angaben,
      ueberschreibungen: ueberschreibungen,
    ),
  ),
);

/// Die ausgegebenen Arbeitswerte in Ausgabereihenfolge (aufsteigend nach
/// Nummer): die berechneten plus die manuellen 11 und 20. 08, 09 und 14 bis
/// 19 kommen im Format nicht vor.
final _arbeitswertFelder = [
  ...berechneteArbeitswertFelder,
  'Arbeit_Wert_11',
  'Arbeit_Wert_20',
]..sort();

String _escape(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
