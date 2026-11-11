import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../repository/model/berichtsentwurf/berichtsentwurf.dart';
import '../../router/router.dart';
import '../../view_model/jahresbericht/assistent_viewmodel.dart';

/// Wie viele Jahre vor dem laufenden Jahr zur Auswahl stehen.
const _jahreZurueck = 10;

/// Die Jahresbericht-Seite: Berichtsjahr wählen und Bericht starten oder
/// fortsetzen, darunter die Liste der vorhandenen Entwürfe mit Status.
class JahresberichtScreen extends ConsumerStatefulWidget {
  const JahresberichtScreen({super.key});

  @override
  ConsumerState<JahresberichtScreen> createState() =>
      _JahresberichtScreenState();
}

class _JahresberichtScreenState extends ConsumerState<JahresberichtScreen> {
  int _jahr = DateTime.now().year;
  bool _beschaeftigt = false;

  Future<void> _oeffne(int jahr, {required bool anlegen}) async {
    if (_beschaeftigt) return;
    setState(() => _beschaeftigt = true);
    try {
      if (anlegen) {
        await ref
            .read(berichtsentwuerfeViewModelProvider.notifier)
            .starten(jahr);
      }
      if (!mounted) return;
      JahresberichtAssistentRoute(berichtsjahr: jahr).go(context);
    } finally {
      if (mounted) setState(() => _beschaeftigt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entwuerfe = ref.watch(berichtsentwuerfeViewModelProvider);

    return entwuerfe.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Fehler: $error')),
      data: (liste) {
        final aktuellesJahr = DateTime.now().year;
        final jahre = {
          for (var j = aktuellesJahr; j >= aktuellesJahr - _jahreZurueck; j--)
            j,
          ...liste.map((e) => e.year),
          _jahr,
        }.toList()..sort((a, b) => b.compareTo(a));
        final vorhanden = liste.any((e) => e.year == _jahr);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.jahresberichtListeTitel,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                DropdownMenu<int>(
                  key: const Key('jahresbericht_jahr'),
                  label: Text(l10n.jahresberichtListeBerichtsjahr),
                  initialSelection: _jahr,
                  enabled: !_beschaeftigt,
                  requestFocusOnTap: false,
                  dropdownMenuEntries: [
                    for (final j in jahre)
                      DropdownMenuEntry(value: j, label: '$j'),
                  ],
                  onSelected: (j) {
                    if (j != null) setState(() => _jahr = j);
                  },
                ),
                const SizedBox(width: 16),
                FilledButton(
                  key: const Key('jahresbericht_starten'),
                  onPressed: _beschaeftigt
                      ? null
                      : () => _oeffne(_jahr, anlegen: !vorhanden),
                  child: Text(
                    vorhanden
                        ? l10n.jahresberichtListeFortsetzen
                        : l10n.jahresberichtListeStarten,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              l10n.jahresberichtListeBestehende,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (liste.isEmpty)
              Text(l10n.jahresberichtListeLeer)
            else
              for (final e in liste)
                Card(
                  child: ListTile(
                    key: Key('jahresbericht_eintrag_${e.year}'),
                    title: Text(
                      l10n.jahresberichtListeBerichtsjahrEintrag(e.year),
                    ),
                    subtitle: Text(_status(l10n, e)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _beschaeftigt
                        ? null
                        : () => _oeffne(e.year, anlegen: false),
                  ),
                ),
          ],
        );
      },
    );
  }

  String _status(AppLocalizations l10n, Berichtsentwurf e) =>
      switch (e.status) {
        EntwurfStatus.entwurf => l10n.jahresberichtStatusEntwurf,
        EntwurfStatus.exportiert =>
          e.exportedAt == null
              ? l10n.jahresberichtStatusEntwurf
              : l10n.jahresberichtStatusExportiert(e.exportedAt!),
      };
}
