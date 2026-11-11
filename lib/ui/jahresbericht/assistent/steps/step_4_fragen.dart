import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../jahresbericht/manuelle_angaben.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../view_model/jahresbericht/assistent_viewmodel.dart';

/// Fragetext der Frage [nummer] (1…[anzahlFragen]).
String _fragetext(AppLocalizations l10n, int nummer) => switch (nummer) {
  1 => l10n.jahresberichtSchritt4Frage01,
  2 => l10n.jahresberichtSchritt4Frage02,
  3 => l10n.jahresberichtSchritt4Frage03,
  4 => l10n.jahresberichtSchritt4Frage04,
  5 => l10n.jahresberichtSchritt4Frage05,
  6 => l10n.jahresberichtSchritt4Frage06,
  7 => l10n.jahresberichtSchritt4Frage07,
  8 => l10n.jahresberichtSchritt4Frage08,
  9 => l10n.jahresberichtSchritt4Frage09,
  10 => l10n.jahresberichtSchritt4Frage10,
  11 => l10n.jahresberichtSchritt4Frage11,
  12 => l10n.jahresberichtSchritt4Frage12,
  13 => l10n.jahresberichtSchritt4Frage13,
  14 => l10n.jahresberichtSchritt4Frage14,
  15 => l10n.jahresberichtSchritt4Frage15,
  16 => l10n.jahresberichtSchritt4Frage16,
  _ => throw RangeError.range(nummer, 1, anzahlFragen, 'nummer'),
};

/// Die vier Fragengruppen mit ihren Fragenummern.
List<(String, List<int>)> _gruppen(AppLocalizations l10n) => [
  (l10n.jahresberichtSchritt4GruppeTeilnahme, [1, 2, 3]),
  (l10n.jahresberichtSchritt4GruppeAktivitaeten, [4, 5, 6, 7]),
  (l10n.jahresberichtSchritt4GruppeWettbewerbe, [8, 9, 10, 11, 12]),
  (l10n.jahresberichtSchritt4GruppeSonstiges, [13, 14, 15, 16]),
];

/// Schritt 4: Fragen (#223).
///
/// Die 16 Ja/Nein-Fragen in vier Gruppen. Unbeantwortete Fragen sind mit
/// "Offen" markiert; eine Antwort lässt sich durch erneutes Anklicken
/// zurücknehmen. Die Antworten gehen sofort in den Entwurf, gespeichert wird
/// beim Verlassen des Schritts.
class Step4Fragen extends ConsumerWidget {
  final int berichtsjahr;

  const Step4Fragen({super.key, required this.berichtsjahr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = jahresberichtAssistentViewModelProvider(berichtsjahr);
    final angaben = ref.watch(provider).requireValue.entwurf.angaben;
    final viewModel = ref.read(provider.notifier);
    final offen = anzahlFragen - angaben.fragen.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.jahresberichtSchritt4Titel,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(l10n.jahresberichtSchritt4Einleitung),
        const SizedBox(height: 8),
        Text(
          offen == 0
              ? l10n.jahresberichtSchritt4AlleBeantwortet
              : l10n.jahresberichtSchritt4OffenAnzahl(offen),
          key: const Key('schritt4_offen_anzahl'),
          style: theme.textTheme.titleSmall?.copyWith(
            color: offen == 0
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
        ),
        for (final (titel, nummern) in _gruppen(l10n)) ...[
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 4),
            child: Text(titel, style: theme.textTheme.titleMedium),
          ),
          for (final nummer in nummern)
            _FrageZeile(
              nummer: nummer,
              text: _fragetext(l10n, nummer),
              antwort: angaben.frage(nummer),
              onAntwort: (antwort) =>
                  viewModel.aendereAngaben((a) => a.withFrage(nummer, antwort)),
            ),
        ],
      ],
    );
  }
}

/// Eine Frage mit Ja/Nein-Auswahl; unbeantwortet ist sie markiert.
class _FrageZeile extends StatelessWidget {
  final int nummer;
  final String text;

  /// `null` = unbeantwortet.
  final bool? antwort;
  final ValueChanged<bool?> onAntwort;

  const _FrageZeile({
    required this.nummer,
    required this.text,
    required this.antwort,
    required this.onAntwort,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final offen = antwort == null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: offen
                ? Chip(
                    key: Key('schritt4_offen_$nummer'),
                    avatar: Icon(
                      Icons.help_outline,
                      size: 16,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    label: Text(l10n.jahresberichtSchritt4Offen),
                    backgroundColor: theme.colorScheme.errorContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          SegmentedButton<bool>(
            key: Key('schritt4_frage_$nummer'),
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: true,
                label: Text(l10n.jahresberichtSchritt4Ja),
              ),
              ButtonSegment(
                value: false,
                label: Text(l10n.jahresberichtSchritt4Nein),
              ),
            ],
            selected: {?antwort},
            onSelectionChanged: (auswahl) =>
                onAntwort(auswahl.isEmpty ? null : auswahl.first),
          ),
        ],
      ),
    );
  }
}
