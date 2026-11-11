import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../view_model/jahresbericht/assistent_viewmodel.dart';

/// Schritt 5: Einsatzabteilung (#223).
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
class _ZahlFeld extends StatefulWidget {
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
  State<_ZahlFeld> createState() => _ZahlFeldState();
}

class _ZahlFeldState extends State<_ZahlFeld> {
  late final TextEditingController _controller;
  bool _ungueltig = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.wert?.toString() ?? '');
  }

  @override
  void didUpdateWidget(_ZahlFeld oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Der Wert hat sich von außen geändert: Feld nachziehen. Eigene gültige
    // Eingaben stimmen schon überein.
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

  /// Gültige Eingabe als Zahl (`null` für leer); `null` als Ergebnis bei
  /// ungültiger Eingabe.
  ({int? wert})? _lies(String text) {
    final t = text.trim();
    if (t.isEmpty) return (wert: null);
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
    final leer = _controller.text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 280,
          child: TextField(
            key: Key('schritt5_feld_${widget.schluessel}'),
            controller: _controller,
            keyboardType: TextInputType.number,
            // Kein Ziffernfilter: ungültige Eingabe soll gemeldet statt still
            // verworfen werden.
            inputFormatters: [LengthLimitingTextInputFormatter(9)],
            decoration: InputDecoration(
              labelText: widget.bezeichnung,
              border: const OutlineInputBorder(),
              helperText: leer && !_ungueltig
                  ? l10n.jahresberichtSchritt5Offen
                  : null,
              errorText: _ungueltig
                  ? l10n.jahresberichtSchritt5FehlerZahl
                  : null,
              errorMaxLines: 3,
            ),
            onChanged: _geaendert,
          ),
        ),
      ),
    );
  }
}
