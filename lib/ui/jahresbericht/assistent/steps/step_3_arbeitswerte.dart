import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../jahresbericht/jahresbericht.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../repository/model/model.dart';
import '../../../../view_model/jahresbericht/assistent_viewmodel.dart';

/// Bezeichnung eines berechneten Arbeitswerts.
String _bezeichnung(AppLocalizations l10n, String feld) => switch (feld) {
  'Arbeit_Wert_01' => l10n.jahresberichtSchritt3Gruppenabende(
    Berichtsthema.feuerwehrtechnik.display,
  ),
  'Arbeit_Wert_02' => l10n.jahresberichtSchritt3Gruppenabende(
    Berichtsthema.wettbewerbstraining.display,
  ),
  'Arbeit_Wert_03' => l10n.jahresberichtSchritt3Gruppenabende(
    Berichtsthema.spieleUndKreatives.display,
  ),
  'Arbeit_Wert_04' => l10n.jahresberichtSchritt3Gruppenabende(
    Berichtsthema.mitAnderemVereinOderGruppe.display,
  ),
  'Arbeit_Wert_05' => l10n.jahresberichtSchritt3Gruppenabende(
    Berichtsthema.sport.display,
  ),
  'Arbeit_Wert_06' => l10n.jahresberichtSchritt3Gruppenabende(
    Berichtsthema.ersteHilfeUndPraevention.display,
  ),
  'Arbeit_Wert_07' => l10n.jahresberichtSchritt3Gruppenabende(
    Berichtsthema.sonstiges.display,
  ),
  'Arbeit_Wert_10' => l10n.jahresberichtSchritt3Dauer,
  'Arbeit_Wert_12' => l10n.jahresberichtSchritt3Betreuerzahl,
  'Arbeit_Wert_13' => l10n.jahresberichtSchritt3Tagesveranstaltungen,
  _ => feld,
};

/// Die berechneten Arbeitswerte in Reihenfolge der Felder.
const _berechneteFelder = [
  'Arbeit_Wert_01',
  'Arbeit_Wert_02',
  'Arbeit_Wert_03',
  'Arbeit_Wert_04',
  'Arbeit_Wert_05',
  'Arbeit_Wert_06',
  'Arbeit_Wert_07',
  'Arbeit_Wert_10',
  'Arbeit_Wert_12',
  'Arbeit_Wert_13',
];

/// Schritt 3: Arbeitswerte (#222).
///
/// Zeigt die berechneten Werte, jeden mit Eingabefeld zum Überschreiben (die
/// Überschreibung ist markiert und lässt sich zurücknehmen), und die
/// manuellen Werte 11 und 20. Gültige Eingaben gehen sofort in den Entwurf;
/// ungültige (keine ganze Zahl, negativ) werden am Feld gemeldet und nicht
/// übernommen. Gespeichert wird beim Verlassen des Schritts.
class Step3Arbeitswerte extends ConsumerWidget {
  final int berichtsjahr;

  const Step3Arbeitswerte({super.key, required this.berichtsjahr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = jahresberichtAssistentViewModelProvider(berichtsjahr);
    final daten = ref.watch(provider).requireValue;
    final viewModel = ref.read(provider.notifier);
    final ueberschreibungen = daten.entwurf.ueberschreibungen;

    void setzeUeberschreibung(String feld, int? wert) {
      viewModel.aendereUeberschreibungen((alt) {
        final map = {...alt.toMap()};
        if (wert == null || wert == daten.berechnet[feld]) {
          map.remove(feld);
        } else {
          map[feld] = wert;
        }
        return Ueberschreibungen(map);
      });
    }

    Widget abschnitt(String titel, List<Widget> kinder) => Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...kinder,
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.jahresberichtSchritt3Titel,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(l10n.jahresberichtSchritt3Einleitung),
        abschnitt(l10n.jahresberichtSchritt3BerechnetTitel, [
          for (final feld in _berechneteFelder)
            _ZahlZeile(
              feld: feld,
              bezeichnung: _bezeichnung(l10n, feld),
              hinweis: feld == 'Arbeit_Wert_13'
                  ? l10n.jahresberichtSchritt3TagesveranstaltungenHinweis
                  : null,
              wert: daten.berichtswert[feld],
              berechnet: ueberschreibungen.toMap().containsKey(feld)
                  ? daten.berechnet[feld]
                  : null,
              erlaubtLeer: false,
              onWert: (wert) => setzeUeberschreibung(feld, wert),
              onZuruecknehmen: () => setzeUeberschreibung(feld, null),
            ),
        ]),
        abschnitt(l10n.jahresberichtSchritt3ManuellTitel, [
          _ZahlZeile(
            feld: 'Arbeit_Wert_11',
            bezeichnung: l10n.jahresberichtSchritt3Vorbereitung,
            wert: daten.entwurf.angaben.arbeitWert11,
            erlaubtLeer: true,
            onWert: (wert) =>
                viewModel.aendereAngaben((a) => a.copyWith(arbeitWert11: wert)),
          ),
          _ZahlZeile(
            feld: 'Arbeit_Wert_20',
            bezeichnung: l10n.jahresberichtSchritt3SonstigeArbeit,
            wert: daten.entwurf.angaben.arbeitWert20,
            erlaubtLeer: true,
            onWert: (wert) =>
                viewModel.aendereAngaben((a) => a.copyWith(arbeitWert20: wert)),
          ),
        ]),
      ],
    );
  }
}

/// Eine Zeile: Bezeichnung, Zahlenfeld und (bei einem überschriebenen
/// Wert) Markierung mit dem berechneten Wert und Zurücknehmen.
class _ZahlZeile extends StatefulWidget {
  final String feld;
  final String bezeichnung;
  final String? hinweis;

  /// Aktueller Wert im Entwurf (`null` = nicht beantwortet).
  final int? wert;

  /// Der berechnete Wert, wenn [wert] ihn überschreibt; sonst `null`.
  final int? berechnet;

  /// Leere Eingabe heißt "nicht beantwortet" statt Fehler.
  final bool erlaubtLeer;

  /// Wird mit jeder gültigen Eingabe aufgerufen.
  final ValueChanged<int?> onWert;
  final VoidCallback? onZuruecknehmen;

  const _ZahlZeile({
    required this.feld,
    required this.bezeichnung,
    required this.wert,
    required this.erlaubtLeer,
    required this.onWert,
    this.hinweis,
    this.berechnet,
    this.onZuruecknehmen,
  });

  @override
  State<_ZahlZeile> createState() => _ZahlZeileState();
}

class _ZahlZeileState extends State<_ZahlZeile> {
  late final TextEditingController _controller;
  bool _ungueltig = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.wert?.toString() ?? '');
  }

  @override
  void didUpdateWidget(_ZahlZeile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Der Wert hat sich von außen geändert (Zurücknehmen, Neuladen): Feld
    // nachziehen. Eigene gültige Eingaben stimmen schon überein.
    if (oldWidget.wert != widget.wert) {
      final eingabe = _lies(_controller.text);
      if (eingabe == null || eingabe.wert != widget.wert) {
        _controller.text = widget.wert?.toString() ?? '';
        _ungueltig = false;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Gültige Eingabe als Zahl (oder `null` für leer, wenn erlaubt); `null`
  /// als Ergebnis bei ungültiger Eingabe.
  ({int? wert})? _lies(String text) {
    final t = text.trim();
    if (t.isEmpty) return widget.erlaubtLeer ? (wert: null) : null;
    if (!RegExp(r'^\d+$').hasMatch(t)) return null;
    final zahl = int.tryParse(t);
    return zahl == null ? null : (wert: zahl);
  }

  void _geaendert(String text) {
    final eingabe = _lies(text);
    setState(() => _ungueltig = eingabe == null);
    if (eingabe != null) widget.onWert(eingabe.wert);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ueberschrieben = widget.berechnet != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.bezeichnung),
                  if (widget.hinweis != null)
                    Text(widget.hinweis!, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 220,
            child: TextField(
              key: Key('schritt3_feld_${widget.feld}'),
              controller: _controller,
              keyboardType: TextInputType.number,
              // Kein Ziffernfilter: ungültige Eingabe soll gemeldet statt
              // still verworfen werden.
              inputFormatters: [LengthLimitingTextInputFormatter(9)],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: _ungueltig
                    ? l10n.jahresberichtSchritt3FehlerZahl
                    : null,
                errorMaxLines: 3,
                filled: ueberschrieben,
                fillColor: ueberschrieben
                    ? theme.colorScheme.tertiaryContainer
                    : null,
              ),
              onChanged: _geaendert,
            ),
          ),
          SizedBox(
            width: 320,
            child: ueberschrieben
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        Chip(
                          avatar: const Icon(Icons.edit, size: 16),
                          label: Text(l10n.jahresberichtSchritt3Ueberschrieben),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.jahresberichtSchritt3Berechnet(
                              widget.berechnet!,
                            ),
                          ),
                        ),
                        IconButton(
                          key: Key('schritt3_zuruecknehmen_${widget.feld}'),
                          tooltip: l10n.jahresberichtSchritt3Zuruecknehmen,
                          icon: const Icon(Icons.undo),
                          onPressed: widget.onZuruecknehmen,
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
