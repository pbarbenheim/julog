import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import 'schritt_platzhalter.dart';

/// Schritt 6: Zusammenfassung und Export (#224). Noch ein leerer
/// Platzhalter.
///
/// Zum Füllen: nur diese Datei und die l10n-Schlüssel
/// `jahresberichtSchritt6...` ändern. Den Entwurf liest und ändert der
/// Schritt über `jahresberichtAssistentViewModelProvider(berichtsjahr)`
/// (siehe dessen Doku); gespeichert wird beim Verlassen des Schritts
/// automatisch.
class Step6Zusammenfassung extends StatelessWidget {
  final int berichtsjahr;

  const Step6Zusammenfassung({super.key, required this.berichtsjahr});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SchrittPlatzhalter(titel: l10n.jahresberichtSchritt6Titel);
  }
}
