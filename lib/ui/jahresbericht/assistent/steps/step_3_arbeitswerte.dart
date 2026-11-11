import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import 'schritt_platzhalter.dart';

/// Schritt 3: Arbeitswerte (#222). Noch ein leerer Platzhalter.
///
/// Zum Füllen: nur diese Datei und die l10n-Schlüssel
/// `jahresberichtSchritt3...` ändern. Den Entwurf liest und ändert der
/// Schritt über `jahresberichtAssistentViewModelProvider(berichtsjahr)`
/// (siehe dessen Doku); gespeichert wird beim Verlassen des Schritts
/// automatisch.
class Step3Arbeitswerte extends StatelessWidget {
  final int berichtsjahr;

  const Step3Arbeitswerte({super.key, required this.berichtsjahr});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SchrittPlatzhalter(titel: l10n.jahresberichtSchritt3Titel);
  }
}
