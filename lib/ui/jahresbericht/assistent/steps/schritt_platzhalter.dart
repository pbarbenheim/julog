import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Leerer Inhalt für Schritte, die noch nicht umgesetzt sind. Ein Folgeticket
/// ersetzt die Verwendung in seiner Schritt-Datei durch den echten Inhalt.
class SchrittPlatzhalter extends StatelessWidget {
  final String titel;

  const SchrittPlatzhalter({super.key, required this.titel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titel, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(l10n.jahresberichtAssistentPlatzhalter),
        ],
      ),
    );
  }
}
