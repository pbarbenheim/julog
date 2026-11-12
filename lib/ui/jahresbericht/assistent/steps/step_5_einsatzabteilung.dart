import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../view_model/jahresbericht/assistent_viewmodel.dart';
import '../widgets/zahl_textfeld.dart';

/// Schritt 5: Einsatzabteilung.
///
/// Drei Zahlenfelder (männlich, weiblich, divers) für die unter
/// 27-Jährigen in der Einsatzabteilung. Gültige Eingaben (ganze Zahl
/// `>= 0`) gehen sofort in den Entwurf; ungültige werden am Feld gemeldet
/// und nicht übernommen. Ein leeres Feld heißt "noch nicht angegeben".
/// Gespeichert wird beim Verlassen des Schritts.
class Step5Einsatzabteilung extends ConsumerWidget {
  final int berichtsjahr;

  const Step5Einsatzabteilung({super.key, required this.berichtsjahr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = jahresberichtAssistentViewModelProvider(berichtsjahr);
    final angaben = ref.watch(provider).requireValue.entwurf.angaben;
    final viewModel = ref.read(provider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.jahresberichtSchritt5Titel,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(l10n.jahresberichtSchritt5Einleitung),
        const SizedBox(height: 16),
        _ZahlFeld(
          schluessel: 'M',
          bezeichnung: l10n.jahresberichtSchritt5Maennlich,
          wert: angaben.einsatzabteilungM,
          onWert: (w) =>
              viewModel.aendereAngaben((a) => a.copyWith(einsatzabteilungM: w)),
        ),
        _ZahlFeld(
          schluessel: 'W',
          bezeichnung: l10n.jahresberichtSchritt5Weiblich,
          wert: angaben.einsatzabteilungW,
          onWert: (w) =>
              viewModel.aendereAngaben((a) => a.copyWith(einsatzabteilungW: w)),
        ),
        _ZahlFeld(
          schluessel: 'D',
          bezeichnung: l10n.jahresberichtSchritt5Divers,
          wert: angaben.einsatzabteilungD,
          onWert: (w) =>
              viewModel.aendereAngaben((a) => a.copyWith(einsatzabteilungD: w)),
        ),
      ],
    );
  }
}

/// Ein Zahlenfeld (ganze Zahl `>= 0`, leer = nicht angegeben).
class _ZahlFeld extends StatelessWidget {
  final String schluessel;
  final String bezeichnung;

  /// Aktueller Wert im Entwurf (`null` = nicht angegeben).
  final int? wert;

  /// Wird mit jeder gültigen Eingabe aufgerufen (`null` bei leerem Feld).
  final ValueChanged<int?> onWert;

  const _ZahlFeld({
    required this.schluessel,
    required this.bezeichnung,
    required this.wert,
    required this.onWert,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 280,
          child: ZahlTextFeld(
            feldKey: Key('schritt5_feld_$schluessel'),
            labelText: bezeichnung,
            wert: wert,
            erlaubtLeer: true,
            leerHinweis: l10n.jahresberichtSchritt5Offen,
            fehlerText: l10n.jahresberichtSchritt5FehlerZahl,
            onWert: onWert,
          ),
        ),
      ),
    );
  }
}
