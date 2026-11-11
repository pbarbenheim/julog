import 'package:material_ui/material_ui.dart';

import '../../../l10n/app_localizations.dart';
import 'steps/step_1_zaehlwerte.dart';
import 'steps/step_2_berichtsthemen.dart';
import 'steps/step_3_arbeitswerte.dart';
import 'steps/step_4_fragen.dart';
import 'steps/step_5_einsatzabteilung.dart';
import 'steps/step_6_zusammenfassung.dart';

/// Ein Schritt des Jahresbericht-Assistenten: Titel und Inhalt.
class AssistentSchritt {
  /// Titel des Schritts (l10n-Schlüssel `jahresberichtSchrittNTitel`).
  final String Function(AppLocalizations l10n) titel;

  /// Baut den Inhalt für das [berichtsjahr]. Der Schritt liest und ändert den
  /// Entwurf über `jahresberichtAssistentViewModelProvider(berichtsjahr)`.
  final Widget Function(int berichtsjahr) inhalt;

  const AssistentSchritt({required this.titel, required this.inhalt});
}

/// Die sechs Schritte in Reihenfolge. Jeder Schritt lebt in einer eigenen
/// Datei unter `steps/`; dieses Verzeichnis muss ein Folgeticket nicht
/// ändern, es füllt nur seine Schritt-Datei (und seine l10n-Schlüssel
/// `jahresberichtSchrittN...`).
final List<AssistentSchritt> assistentSchritte = [
  AssistentSchritt(
    titel: (l10n) => l10n.jahresberichtSchritt1Titel,
    inhalt: (jahr) => Step1Zaehlwerte(berichtsjahr: jahr),
  ),
  AssistentSchritt(
    titel: (l10n) => l10n.jahresberichtSchritt2Titel,
    inhalt: (jahr) => Step2Berichtsthemen(berichtsjahr: jahr),
  ),
  AssistentSchritt(
    titel: (l10n) => l10n.jahresberichtSchritt3Titel,
    inhalt: (jahr) => Step3Arbeitswerte(berichtsjahr: jahr),
  ),
  AssistentSchritt(
    titel: (l10n) => l10n.jahresberichtSchritt4Titel,
    inhalt: (jahr) => Step4Fragen(berichtsjahr: jahr),
  ),
  AssistentSchritt(
    titel: (l10n) => l10n.jahresberichtSchritt5Titel,
    inhalt: (jahr) => Step5Einsatzabteilung(berichtsjahr: jahr),
  ),
  AssistentSchritt(
    titel: (l10n) => l10n.jahresberichtSchritt6Titel,
    inhalt: (jahr) => Step6Zusammenfassung(berichtsjahr: jahr),
  ),
];
