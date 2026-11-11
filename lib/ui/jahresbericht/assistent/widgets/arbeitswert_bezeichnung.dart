import '../../../../jahresbericht/jahresbericht.dart';
import '../../../../l10n/app_localizations.dart';

/// Bezeichnung eines berechneten Arbeitswerts (siehe
/// [berechneteArbeitswertFelder]); für ein anderes Feld der Feldname.
String arbeitswertBezeichnung(AppLocalizations l10n, String feld) {
  for (final e in berichtsthemaFeld.entries) {
    if (e.value == feld) {
      return l10n.jahresberichtSchritt3Gruppenabende(e.key.display);
    }
  }
  return switch (feld) {
    'Arbeit_Wert_10' => l10n.jahresberichtSchritt3Dauer,
    'Arbeit_Wert_12' => l10n.jahresberichtSchritt3Betreuerzahl,
    'Arbeit_Wert_13' => l10n.jahresberichtSchritt3Tagesveranstaltungen,
    _ => feld,
  };
}
