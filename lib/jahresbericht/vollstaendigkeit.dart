import '../repository/model/model.dart';
import 'jahresbericht.dart';
import 'manuelle_angaben.dart';

/// Ergebnis der Vollständigkeitsprüfung eines Jahresberichts.
///
/// Der Bericht ist exportierbar, wenn [istVollstaendig] gilt.
class Vollstaendigkeit {
  /// Nummern (1…16) der unbeantworteten Fragen, aufsteigend.
  final List<int> fehlendeFragen;

  /// `Arbeit_Wert_11` (Vor-/Nachbereitungszeit) fehlt.
  final bool arbeitWert11Fehlt;

  /// `Arbeit_Wert_20` (Stunden sonstige Arbeit) fehlt.
  final bool arbeitWert20Fehlt;

  /// Geschlechter, für die `Alter_Anz_EA_bis_27_*` fehlt (M, W, D).
  final List<Gender> fehlendeEinsatzabteilung;

  /// Im Berichtsjahr benutzte Kategorien ohne Berichtsthema.
  final List<Kategorie> kategorienOhneBerichtsthema;

  Vollstaendigkeit({
    required List<int> fehlendeFragen,
    required this.arbeitWert11Fehlt,
    required this.arbeitWert20Fehlt,
    required List<Gender> fehlendeEinsatzabteilung,
    required List<Kategorie> kategorienOhneBerichtsthema,
  }) : fehlendeFragen = List.unmodifiable(fehlendeFragen),
       fehlendeEinsatzabteilung = List.unmodifiable(fehlendeEinsatzabteilung),
       kategorienOhneBerichtsthema = List.unmodifiable(
         kategorienOhneBerichtsthema,
       );

  /// Nichts fehlt: der Bericht darf exportiert werden.
  bool get istVollstaendig =>
      fehlendeFragen.isEmpty &&
      !arbeitWert11Fehlt &&
      !arbeitWert20Fehlt &&
      fehlendeEinsatzabteilung.isEmpty &&
      kategorienOhneBerichtsthema.isEmpty;

  @override
  String toString() =>
      'Vollstaendigkeit(fehlendeFragen: $fehlendeFragen, '
      'arbeitWert11Fehlt: $arbeitWert11Fehlt, '
      'arbeitWert20Fehlt: $arbeitWert20Fehlt, '
      'fehlendeEinsatzabteilung: $fehlendeEinsatzabteilung, '
      'kategorienOhneBerichtsthema: $kategorienOhneBerichtsthema)';
}

/// Prüft, ob für [berichtsjahr] alle manuellen [angaben] vorliegen und alle im
/// Jahr benutzten [kategorien] (laut [eintraege]) ein Berichtsthema haben.
Vollstaendigkeit pruefeVollstaendigkeit({
  required int berichtsjahr,
  required ManuelleAngaben angaben,
  required List<Kategorie> kategorien,
  required List<Eintrag> eintraege,
}) => Vollstaendigkeit(
  fehlendeFragen: [
    for (var n = 1; n <= anzahlFragen; n++)
      if (angaben.frage(n) == null) n,
  ],
  arbeitWert11Fehlt: angaben.arbeitWert11 == null,
  arbeitWert20Fehlt: angaben.arbeitWert20 == null,
  fehlendeEinsatzabteilung: [
    if (angaben.einsatzabteilungM == null) Gender.male,
    if (angaben.einsatzabteilungW == null) Gender.female,
    if (angaben.einsatzabteilungD == null) Gender.diverse,
  ],
  kategorienOhneBerichtsthema: kategorienOhneBerichtsthema(
    berichtsjahr: berichtsjahr,
    kategorien: kategorien,
    eintraege: eintraege,
  ),
);
