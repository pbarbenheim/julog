import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../jahresbericht/jahresbericht.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../view_model/jahresbericht/assistent_viewmodel.dart';
import '../widgets/abschnitt.dart';
import '../widgets/arbeitswert_bezeichnung.dart';
import '../widgets/ueberschrieben_hinweis.dart';
import '../widgets/zahl_textfeld.dart';

/// Schritt 3: Arbeitswerte.
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.jahresberichtSchritt3Titel,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(l10n.jahresberichtSchritt3Einleitung),
        Abschnitt(
          titel: l10n.jahresberichtSchritt3BerechnetTitel,
          inhalt: Column(
            children: [
              for (final feld in berechneteArbeitswertFelder)
                _ZahlZeile(
                  feld: feld,
                  bezeichnung: arbeitswertBezeichnung(l10n, feld),
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
            ],
          ),
        ),
        Abschnitt(
          titel: l10n.jahresberichtSchritt3ManuellTitel,
          inhalt: Column(
            children: [
              _ZahlZeile(
                feld: 'Arbeit_Wert_11',
                bezeichnung: l10n.jahresberichtSchritt3Vorbereitung,
                wert: daten.entwurf.angaben.arbeitWert11,
                erlaubtLeer: true,
                onWert: (wert) => viewModel.aendereAngaben(
                  (a) => a.copyWith(arbeitWert11: wert),
                ),
              ),
              _ZahlZeile(
                feld: 'Arbeit_Wert_20',
                bezeichnung: l10n.jahresberichtSchritt3SonstigeArbeit,
                wert: daten.entwurf.angaben.arbeitWert20,
                erlaubtLeer: true,
                onWert: (wert) => viewModel.aendereAngaben(
                  (a) => a.copyWith(arbeitWert20: wert),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Eine Zeile: Bezeichnung, Zahlenfeld und (bei einem überschriebenen
/// Wert) Markierung mit dem berechneten Wert und Zurücknehmen.
class _ZahlZeile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ueberschrieben = berechnet != null;

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
                  Text(bezeichnung),
                  if (hinweis != null)
                    Text(hinweis!, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 220,
            child: ZahlTextFeld(
              feldKey: Key('schritt3_feld_$feld'),
              wert: wert,
              erlaubtLeer: erlaubtLeer,
              fehlerText: l10n.jahresberichtSchritt3FehlerZahl,
              fuellfarbe: ueberschrieben
                  ? theme.colorScheme.tertiaryContainer
                  : null,
              onWert: onWert,
            ),
          ),
          SizedBox(
            width: 320,
            child: ueberschrieben
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: UeberschriebenHinweis(berechnet: berechnet!),
                        ),
                        IconButton(
                          key: Key('schritt3_zuruecknehmen_$feld'),
                          tooltip: l10n.jahresberichtSchritt3Zuruecknehmen,
                          icon: const Icon(Icons.undo),
                          onPressed: onZuruecknehmen,
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
