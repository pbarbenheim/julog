import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../jahresbericht/jahresbericht.dart';
import '../../../../jahresbericht/manuelle_angaben.dart';
import '../../../../jahresbericht/vollstaendigkeit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../repository/model/berichtsentwurf/berichtsentwurf.dart';
import '../../../../repository/model/model.dart';
import '../../../../view_model/jahresbericht/assistent_viewmodel.dart';
import '../widgets/abschnitt.dart';
import '../widgets/arbeitswert_bezeichnung.dart';
import '../widgets/ueberschrieben_hinweis.dart';

/// Schritt 6: Zusammenfassung und Export.
///
/// Zeigt alle Zählwerte, Arbeitswerte (überschriebene markiert) und
/// manuellen Angaben zur Kontrolle. Fehlt etwas, nennt die Seite, was und in
/// welchem Schritt, und der Export ist gesperrt. Sonst schreibt der Export
/// die XML an das Ziel, das der Anwender im Speichern-Dialog wählt (siehe
/// [JahresberichtAssistentViewModel.exportiere]), und markiert den Bericht als
/// exportiert. Das lässt sich beliebig oft wiederholen.
class Step6Zusammenfassung extends ConsumerStatefulWidget {
  final int berichtsjahr;

  const Step6Zusammenfassung({super.key, required this.berichtsjahr});

  @override
  ConsumerState<Step6Zusammenfassung> createState() =>
      _Step6ZusammenfassungState();
}

class _Step6ZusammenfassungState extends ConsumerState<Step6Zusammenfassung> {
  bool _beschaeftigt = false;

  int get _jahr => widget.berichtsjahr;

  Future<void> _exportiere() async {
    if (_beschaeftigt) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = ref.read(
      jahresberichtAssistentViewModelProvider(_jahr).notifier,
    );
    setState(() => _beschaeftigt = true);
    try {
      final ergebnis = await viewModel.exportiere(
        bestaetigenText: l10n.jahresberichtSchritt6ExportBestaetigen,
      );
      final meldung = switch (ergebnis) {
        ExportAbgebrochen() => null,
        ExportErfolgreich(:final pfad) =>
          l10n.jahresberichtSchritt6ExportErfolg(pfad),
        ExportStatusNichtGespeichert(:final pfad, :final fehler) =>
          l10n.jahresberichtSchritt6ExportStatusFehler(pfad, '$fehler'),
      };
      if (meldung != null) {
        messenger.showSnackBar(SnackBar(content: Text(meldung)));
      }
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.jahresberichtSchritt6ExportFehler(e.toString())),
        ),
      );
    } finally {
      if (mounted) setState(() => _beschaeftigt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final daten = ref
        .watch(jahresberichtAssistentViewModelProvider(_jahr))
        .requireValue;
    final entwurf = daten.entwurf;
    final vollstaendigkeit = pruefeVollstaendigkeit(
      berichtsjahr: _jahr,
      angaben: entwurf.angaben,
      kategorien: daten.kategorien,
      eintraege: daten.eintraege,
    );
    final exportiertAm = entwurf.status == EntwurfStatus.exportiert
        ? entwurf.exportedAt
        : null;
    final wurdeExportiert = exportiertAm != null;

    final wert = daten.berichtswert;
    int w(String feld) => wert[feld];
    final ueberschrieben = entwurf.ueberschreibungen.toMap().keys.toSet();

    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.jahresberichtSchritt6Titel,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(l10n.jahresberichtSchritt6Einleitung),
          const SizedBox(height: 16),
          _Vollstaendigkeitshinweis(
            l10n: l10n,
            vollstaendigkeit: vollstaendigkeit,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                key: const Key('schritt6_export'),
                onPressed: vollstaendigkeit.istVollstaendig && !_beschaeftigt
                    ? _exportiere
                    : null,
                icon: const Icon(Icons.file_download_outlined),
                label: Text(
                  wurdeExportiert
                      ? l10n.jahresberichtSchritt6ErneutExportieren
                      : l10n.jahresberichtSchritt6Exportieren,
                ),
              ),
              const SizedBox(width: 16),
              if (exportiertAm != null)
                Text(
                  l10n.jahresberichtSchritt6ZuletztExportiert(exportiertAm),
                  key: const Key('schritt6_zuletzt_exportiert'),
                ),
            ],
          ),
          Abschnitt(
            titel: l10n.jahresberichtSchritt6ZaehlwerteTitel,
            inhalt: _Zaehlwerte(l10n: l10n, wert: wert),
          ),
          Abschnitt(
            titel: l10n.jahresberichtSchritt6ArbeitswerteTitel,
            inhalt: Column(
              children: [
                for (final feld in berechneteArbeitswertFelder)
                  _WertZeile(
                    feld: feld,
                    bezeichnung: arbeitswertBezeichnung(l10n, feld),
                    wert: w(feld),
                    berechnet: ueberschrieben.contains(feld)
                        ? daten.berechnet[feld]
                        : null,
                    l10n: l10n,
                  ),
              ],
            ),
          ),
          Abschnitt(
            titel: l10n.jahresberichtSchritt6AngabenTitel,
            inhalt: _Angaben(l10n: l10n, angaben: entwurf.angaben),
          ),
        ],
      ),
    );
  }
}

class _Vollstaendigkeitshinweis extends StatelessWidget {
  final AppLocalizations l10n;
  final Vollstaendigkeit vollstaendigkeit;

  const _Vollstaendigkeitshinweis({
    required this.l10n,
    required this.vollstaendigkeit,
  });

  @override
  Widget build(BuildContext context) {
    final v = vollstaendigkeit;
    if (v.istVollstaendig) {
      return Card(
        key: const Key('schritt6_vollstaendig'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.jahresberichtSchritt6Vollstaendig)),
            ],
          ),
        ),
      );
    }
    String fehlt(int schritt, String titel, String was) =>
        l10n.jahresberichtSchritt6Fehlt(schritt, titel, was);
    final eintraege = [
      if (v.kategorienOhneBerichtsthema.isNotEmpty)
        fehlt(
          2,
          l10n.jahresberichtSchritt2Titel,
          l10n.jahresberichtSchritt6FehltKategorien(
            v.kategorienOhneBerichtsthema.map((k) => k.name).join(', '),
          ),
        ),
      if (v.arbeitWert11Fehlt)
        fehlt(
          3,
          l10n.jahresberichtSchritt3Titel,
          l10n.jahresberichtSchritt6FehltVorbereitung,
        ),
      if (v.arbeitWert20Fehlt)
        fehlt(
          3,
          l10n.jahresberichtSchritt3Titel,
          l10n.jahresberichtSchritt6FehltSonstigeArbeit,
        ),
      if (v.fehlendeFragen.isNotEmpty)
        fehlt(
          4,
          l10n.jahresberichtSchritt4Titel,
          l10n.jahresberichtSchritt6FehltFragen(v.fehlendeFragen.join(', ')),
        ),
      if (v.fehlendeEinsatzabteilung.isNotEmpty)
        fehlt(
          5,
          l10n.jahresberichtSchritt5Titel,
          l10n.jahresberichtSchritt6FehltEinsatzabteilung(
            v.fehlendeEinsatzabteilung.map((g) => g.display).join(', '),
          ),
        ),
    ];
    return Card(
      key: const Key('schritt6_fehlt'),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.jahresberichtSchritt6Unvollstaendig)),
              ],
            ),
            const SizedBox(height: 8),
            for (final e in eintraege)
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 4),
                child: Text('• $e'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Eine Zeile mit Bezeichnung und Wert; bei einem überschriebenen Wert mit
/// Markierung und dem berechneten Wert ([berechnet]).
class _WertZeile extends StatelessWidget {
  final String feld;
  final String bezeichnung;
  final int wert;
  final int? berechnet;
  final AppLocalizations l10n;

  const _WertZeile({
    required this.feld,
    required this.bezeichnung,
    required this.wert,
    required this.l10n,
    this.berechnet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(bezeichnung)),
          if (berechnet != null) ...[
            UeberschriebenHinweis(berechnet: berechnet!),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 64,
            child: Text(
              '$wert',
              key: Key('schritt6_wert_$feld'),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alle berechneten Zählwerte als Tabellen (Zeile je Wert, Spalten M, W, D
/// und Gesamt) plus die Abgangsgründe.
class _Zaehlwerte extends StatelessWidget {
  final AppLocalizations l10n;
  final Berichtswert wert;

  const _Zaehlwerte({required this.l10n, required this.wert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget gruppe(String titel, List<(String, String)> zeilen) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titel, style: theme.textTheme.titleSmall),
          _GeschlechterTabelle(l10n: l10n, wert: wert, zeilen: zeilen),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gruppe(l10n.jahresberichtSchritt1Mitglieder, [('', 'Mitglieder_Anz')]),
        gruppe(l10n.jahresberichtSchritt1Alter, [
          (l10n.jahresberichtSchritt1AlterUnter5, 'Alter_Anz_unter_5'),
          for (var a = 5; a <= 18; a++)
            (
              l10n.jahresberichtSchritt1AlterJahre(a),
              'Alter_Anz_${a.toString().padLeft(2, '0')}',
            ),
          (l10n.jahresberichtSchritt1AlterUeber18, 'Alter_Anz_über_18'),
        ]),
        gruppe(l10n.jahresberichtSchritt1Betreuer, [('', 'Betreuer_Anz')]),
        gruppe(l10n.jahresberichtSchritt1Zugang, [
          (Herkunft.neu.display, 'Zugang_Anz_Neu'),
          (Herkunft.andereOrganisation.display, 'Zugang_Anz_AO'),
          (Herkunft.kinderfeuerwehr.display, 'Zugang_Anz_KF'),
        ]),
        gruppe(l10n.jahresberichtSchritt1Abgang, [
          (l10n.jahresberichtSchritt1AbgangEinsatzabteilung, 'Abgang_Anz_EA'),
          (l10n.jahresberichtSchritt1AbgangSonstige, 'Abgang_Anz_SO'),
        ]),
        Text(
          l10n.jahresberichtSchritt1AbgangGruende,
          style: theme.textTheme.titleSmall,
        ),
        for (final (grund, feld) in _abgangGruende)
          _WertZeile(
            feld: feld,
            bezeichnung: grund.display,
            wert: wert[feld],
            l10n: l10n,
          ),
      ],
    );
  }
}

const _abgangGruende = [
  (AustrittsGrund.wohnortwechsel, 'Grund_SO_Wohnort'),
  (AustrittsGrund.noInterest, 'Grund_SO_Interesse'),
  (AustrittsGrund.schule, 'Grund_SO_Schule'),
  (AustrittsGrund.ausbildung, 'Grund_SO_Beruf'),
  (AustrittsGrund.ausschluss, 'Grund_SO_Verweis'),
  (AustrittsGrund.noUebernahme, 'Grund_SO_Übernahme'),
];

/// Tabelle mit Zeilen für Feldpräfixe; die Spalten sind `<präfix>_M`, `_W`
/// und `_D` und die Summe.
class _GeschlechterTabelle extends StatelessWidget {
  final AppLocalizations l10n;
  final Berichtswert wert;
  final List<(String, String)> zeilen;

  const _GeschlechterTabelle({
    required this.l10n,
    required this.wert,
    required this.zeilen,
  });

  @override
  Widget build(BuildContext context) {
    DataCell zelle(String praefix, String suffix) => DataCell(
      Text(
        '${wert['${praefix}_$suffix']}',
        key: Key('schritt6_wert_${praefix}_$suffix'),
      ),
    );
    return DataTable(
      dataRowMinHeight: 32,
      dataRowMaxHeight: 32,
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
        for (final (label, praefix) in zeilen)
          DataRow(
            cells: [
              DataCell(Text(label)),
              zelle(praefix, 'M'),
              zelle(praefix, 'W'),
              zelle(praefix, 'D'),
              DataCell(
                Text(
                  '${wert['${praefix}_M'] + wert['${praefix}_W'] + wert['${praefix}_D']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Die manuellen Angaben: Werte 11 und 20, Einsatzabteilung und die
/// Antworten auf die Ja/Nein-Fragen.
class _Angaben extends StatelessWidget {
  final AppLocalizations l10n;
  final ManuelleAngaben angaben;

  const _Angaben({required this.l10n, required this.angaben});

  @override
  Widget build(BuildContext context) {
    Widget zeile(String schluessel, String bezeichnung, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(bezeichnung)),
          SizedBox(
            width: 64,
            child: Text(
              text,
              key: Key(schluessel),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    String zahl(int? n) => n == null ? l10n.jahresberichtSchritt6Offen : '$n';

    return Column(
      children: [
        zeile(
          'schritt6_wert_Arbeit_Wert_11',
          l10n.jahresberichtSchritt3Vorbereitung,
          zahl(angaben.arbeitWert11),
        ),
        zeile(
          'schritt6_wert_Arbeit_Wert_20',
          l10n.jahresberichtSchritt3SonstigeArbeit,
          zahl(angaben.arbeitWert20),
        ),
        for (final (gender, anzahl) in [
          (Gender.male, angaben.einsatzabteilungM),
          (Gender.female, angaben.einsatzabteilungW),
          (Gender.diverse, angaben.einsatzabteilungD),
        ])
          zeile(
            'schritt6_wert_Alter_Anz_EA_bis_27_${switch (gender) {
              Gender.male => 'M',
              Gender.female => 'W',
              Gender.diverse => 'D',
            }}',
            '${l10n.jahresberichtSchritt6Einsatzabteilung} (${gender.display})',
            zahl(anzahl),
          ),
        const Divider(),
        for (var n = 1; n <= anzahlFragen; n++)
          zeile(
            'schritt6_frage_$n',
            l10n.jahresberichtSchritt6Frage(n),
            switch (angaben.frage(n)) {
              true => l10n.jahresberichtSchritt6Ja,
              false => l10n.jahresberichtSchritt6Nein,
              null => l10n.jahresberichtSchritt6Offen,
            },
          ),
      ],
    );
  }
}
