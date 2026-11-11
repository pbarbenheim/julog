import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../jahresbericht/jahresbericht.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../repository/model/model.dart';
import '../../../../view_model/jahresbericht/assistent_viewmodel.dart';

/// Schritt 2: Berichtsthemen zuordnen.
///
/// Zeigt die im Berichtsjahr benutzten Kategorien, die beim Öffnen des
/// Schritts noch kein Berichtsthema hatten. Eine Zuordnung wird sofort an der
/// Kategorie gespeichert (sie gilt dauerhaft, nicht nur für diesen Entwurf)
/// und die Stammdaten des Assistenten werden neu geladen, damit die
/// Folgeschritte die geänderten Arbeitswerte sehen. Zugeordnete Kategorien
/// bleiben im Schritt sichtbar, damit die Wahl korrigiert werden kann.
class Step2Berichtsthemen extends ConsumerStatefulWidget {
  final int berichtsjahr;

  const Step2Berichtsthemen({super.key, required this.berichtsjahr});

  @override
  ConsumerState<Step2Berichtsthemen> createState() =>
      _Step2BerichtsthemenState();
}

class _Step2BerichtsthemenState extends ConsumerState<Step2Berichtsthemen> {
  late final List<String> _offeneIds;
  final Set<String> _speichernd = {};

  @override
  void initState() {
    super.initState();
    final daten = ref
        .read(jahresberichtAssistentViewModelProvider(widget.berichtsjahr))
        .requireValue;
    _offeneIds = [
      for (final k in kategorienOhneBerichtsthema(
        berichtsjahr: widget.berichtsjahr,
        kategorien: daten.kategorien,
        eintraege: daten.eintraege,
      ))
        k.id,
    ];
  }

  Future<void> _ordneZu(Kategorie kategorie, Berichtsthema thema) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = ref.read(
      jahresberichtAssistentViewModelProvider(widget.berichtsjahr).notifier,
    );
    setState(() => _speichernd.add(kategorie.id));
    try {
      await viewModel.ordneBerichtsthemaZu(kategorie, thema);
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.jahresberichtSchritt2Fehler('$e'))),
      );
    } finally {
      if (mounted) setState(() => _speichernd.remove(kategorie.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final daten = ref
        .watch(jahresberichtAssistentViewModelProvider(widget.berichtsjahr))
        .requireValue;
    final kategorien = [
      for (final k in daten.kategorien)
        if (_offeneIds.contains(k.id)) k,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.jahresberichtSchritt2Titel,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (kategorien.isEmpty)
          Card(
            key: const Key('schritt2_keine_offen'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.jahresberichtSchritt2KeineOffen)),
                ],
              ),
            ),
          )
        else ...[
          Text(l10n.jahresberichtSchritt2Einleitung),
          const SizedBox(height: 16),
          for (final k in kategorien)
            Card(
              key: Key('schritt2_kategorie_${k.id}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(k.name, style: theme.textTheme.titleMedium),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 340,
                      child: DropdownButton<Berichtsthema>(
                        key: Key('schritt2_thema_${k.id}'),
                        isExpanded: true,
                        value: k.berichtsthema,
                        hint: Text(l10n.jahresberichtSchritt2Auswahl),
                        items: [
                          for (final thema in Berichtsthema.values)
                            DropdownMenuItem(
                              value: thema,
                              child: Text(thema.display),
                            ),
                        ],
                        onChanged: _speichernd.contains(k.id)
                            ? null
                            : (thema) {
                                if (thema != null && thema != k.berichtsthema) {
                                  _ordneZu(k, thema);
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}
