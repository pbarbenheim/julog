import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Markierung "Überschrieben" mit dem berechneten Wert ("Berechnet: n") für
/// einen Arbeitswert, den der Anwender überschrieben hat.
class UeberschriebenHinweis extends StatelessWidget {
  final int berechnet;

  const UeberschriebenHinweis({super.key, required this.berechnet});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          avatar: const Icon(Icons.edit, size: 16),
          label: Text(l10n.jahresberichtSchritt3Ueberschrieben),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(l10n.jahresberichtSchritt3Berechnet(berechnet))),
      ],
    );
  }
}
