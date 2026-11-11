import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../repository/model/model.dart';
import '../../../../view_model/jahresbericht/assistent_viewmodel.dart';
import '../../../../view_model/jahresbericht/zaehlwerte_uebersicht.dart';

/// Schritt 1: Jahr und Übersicht der Zählwerte (schreibgeschützt).
class Step1Zaehlwerte extends ConsumerWidget {
  final int berichtsjahr;

  const Step1Zaehlwerte({super.key, required this.berichtsjahr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final daten = ref
        .watch(jahresberichtAssistentViewModelProvider(berichtsjahr))
        .requireValue;
    final u = ZaehlwerteUebersicht.von(daten.berichtswert);

    Widget abschnitt(String titel, Widget inhalt) => Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          inhalt,
        ],
      ),
    );

    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.jahresberichtAssistentTitel(berichtsjahr),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.jahresberichtSchritt1Einleitung(
              DateTime(berichtsjahr, 12, 31),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            key: const Key('schritt1_hinweis'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.jahresberichtSchritt1Hinweis)),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    key: const Key('schritt1_neuladen'),
                    onPressed: () => ref
                        .read(
                          jahresberichtAssistentViewModelProvider(
                            berichtsjahr,
                          ).notifier,
                        )
                        .neuLaden(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.jahresberichtSchritt1Neuladen),
                  ),
                ],
              ),
            ),
          ),
          abschnitt(
            l10n.jahresberichtSchritt1Mitglieder,
            _GeschlechterTabelle(l10n: l10n, zeilen: [('', u.mitglieder)]),
          ),
          abschnitt(
            l10n.jahresberichtSchritt1Alter,
            _GeschlechterTabelle(
              l10n: l10n,
              zeilen: [
                (l10n.jahresberichtSchritt1AlterUnter5, u.alterUnter5),
                for (final z in u.alter)
                  (l10n.jahresberichtSchritt1AlterJahre(z.alter), z.werte),
                (l10n.jahresberichtSchritt1AlterUeber18, u.alterUeber18),
              ],
            ),
          ),
          abschnitt(
            l10n.jahresberichtSchritt1Betreuer,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GeschlechterTabelle(l10n: l10n, zeilen: [('', u.betreuer)]),
                const SizedBox(height: 4),
                Text(
                  l10n.jahresberichtSchritt1BetreuerHinweis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          abschnitt(
            l10n.jahresberichtSchritt1Zugang,
            _GeschlechterTabelle(
              l10n: l10n,
              zeilen: [
                (Herkunft.neu.display, u.zugangNeu),
                (
                  Herkunft.andereOrganisation.display,
                  u.zugangAndereOrganisation,
                ),
                (Herkunft.kinderfeuerwehr.display, u.zugangKinderfeuerwehr),
              ],
            ),
          ),
          abschnitt(
            l10n.jahresberichtSchritt1Abgang,
            _GeschlechterTabelle(
              l10n: l10n,
              zeilen: [
                (
                  l10n.jahresberichtSchritt1AbgangEinsatzabteilung,
                  u.abgangEinsatzabteilung,
                ),
                (l10n.jahresberichtSchritt1AbgangSonstige, u.abgangSonstige),
              ],
            ),
          ),
          abschnitt(
            l10n.jahresberichtSchritt1AbgangGruende,
            Column(
              key: const Key('schritt1_abgang_gruende'),
              children: [
                for (final e in u.abgangGruende.entries)
                  SizedBox(
                    width: 420,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(e.key.display), Text('${e.value}')],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabelle mit je einer Zeile pro Eintrag und den Spalten männlich, weiblich,
/// divers und Gesamt.
class _GeschlechterTabelle extends StatelessWidget {
  final AppLocalizations l10n;
  final List<(String, GeschlechterWerte)> zeilen;

  const _GeschlechterTabelle({required this.l10n, required this.zeilen});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      dataRowMinHeight: 36,
      dataRowMaxHeight: 36,
      columns: [
        const DataColumn(label: Text('')),
        DataColumn(label: Text(Gender.male.display), numeric: true),
        DataColumn(label: Text(Gender.female.display), numeric: true),
        DataColumn(label: Text(Gender.diverse.display), numeric: true),
        DataColumn(
          label: Text(l10n.jahresberichtSchritt1Gesamt),
          numeric: true,
        ),
      ],
      rows: [
        for (final (label, w) in zeilen)
          DataRow(
            cells: [
              DataCell(Text(label)),
              DataCell(Text('${w.maennlich}')),
              DataCell(Text('${w.weiblich}')),
              DataCell(Text('${w.divers}')),
              DataCell(
                Text(
                  '${w.gesamt}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
