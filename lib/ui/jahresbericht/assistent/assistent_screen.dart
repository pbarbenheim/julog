import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../../../router/router.dart';
import '../../../view_model/jahresbericht/assistent_viewmodel.dart';
import 'assistent_schritt.dart';

/// Der Jahresbericht-Assistent: sechs Schritte mit Zurück/Weiter.
///
/// Der Entwurf wird beim Verlassen jedes Schritts, beim Schließen und beim
/// Verlassen der Seite (z. B. über das Hauptmenü) gespeichert, siehe
/// `JahresberichtAssistentViewModel.vorVerlassen`.
class AssistentScreen extends ConsumerStatefulWidget {
  final int berichtsjahr;

  const AssistentScreen({super.key, required this.berichtsjahr});

  @override
  ConsumerState<AssistentScreen> createState() => _AssistentScreenState();
}

class _AssistentScreenState extends ConsumerState<AssistentScreen> {
  int _schritt = 0;
  bool _beschaeftigt = false;
  late final JahresberichtAssistentViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final provider = jahresberichtAssistentViewModelProvider(
      widget.berichtsjahr,
    );
    // Hält den Zustand am Leben, bis der Assistent geschlossen ist.
    ref.listenManual(provider, (_, _) {});
    _viewModel = ref.read(provider.notifier);
  }

  @override
  void deactivate() {
    // Seite wird verlassen (Hauptmenü, Datei schließen ...): Entwurf sichern.
    // Fehler hier kann der Anwender nicht mehr behandeln; der Arbeitsstand
    // wird beim nächsten Öffnen aus dem gespeicherten Entwurf geladen.
    unawaited(_viewModel.vorVerlassen().catchError((Object _) {}));
    super.deactivate();
  }

  /// Speichert den Entwurf. `false`, wenn das fehlschlug (der Anwender bleibt
  /// dann im Schritt, damit nichts verloren geht).
  Future<bool> _verlasseSchritt() async {
    try {
      await _viewModel.vorVerlassen();
      return true;
    } on Object catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.jahresberichtAssistentSpeichernFehler(e.toString()),
            ),
          ),
        );
      }
      return false;
    }
  }

  Future<void> _gehZu(int neuerSchritt) async {
    if (_beschaeftigt || neuerSchritt == _schritt) return;
    setState(() => _beschaeftigt = true);
    final ok = await _verlasseSchritt();
    if (!mounted) return;
    setState(() {
      _beschaeftigt = false;
      if (ok) _schritt = neuerSchritt;
    });
  }

  Future<void> _schliessen() async {
    if (_beschaeftigt) return;
    setState(() => _beschaeftigt = true);
    final ok = await _verlasseSchritt();
    if (!mounted) return;
    setState(() => _beschaeftigt = false);
    if (ok) const JahresberichtRoute().go(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final daten = ref.watch(
      jahresberichtAssistentViewModelProvider(widget.berichtsjahr),
    );
    final anzahl = assistentSchritte.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.jahresberichtAssistentTitel(widget.berichtsjahr),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Text(
                l10n.jahresberichtAssistentSchrittVon(_schritt + 1, anzahl),
                key: const Key('assistent_schritt_position'),
              ),
              IconButton(
                key: const Key('assistent_schliessen'),
                tooltip: l10n.jahresberichtAssistentSchliessen,
                onPressed: _beschaeftigt ? null : _schliessen,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (var i = 0; i < anzahl; i++)
                ChoiceChip(
                  key: Key('assistent_schritt_$i'),
                  label: Text('${i + 1}  ${assistentSchritte[i].titel(l10n)}'),
                  selected: i == _schritt,
                  onSelected: _beschaeftigt ? null : (_) => _gehZu(i),
                ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: daten.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text(l10n.jahresberichtFehler('$error'))),
            data: (_) => KeyedSubtree(
              key: ValueKey(_schritt),
              child: assistentSchritte[_schritt].inhalt(widget.berichtsjahr),
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              OutlinedButton.icon(
                key: const Key('assistent_zurueck'),
                onPressed: _beschaeftigt || _schritt == 0
                    ? null
                    : () => _gehZu(_schritt - 1),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.jahresberichtAssistentZurueck),
              ),
              const Spacer(),
              if (_schritt < anzahl - 1)
                FilledButton.icon(
                  key: const Key('assistent_weiter'),
                  onPressed: _beschaeftigt ? null : () => _gehZu(_schritt + 1),
                  icon: const Icon(Icons.arrow_forward),
                  iconAlignment: IconAlignment.end,
                  label: Text(l10n.jahresberichtAssistentWeiter),
                )
              else
                FilledButton(
                  key: const Key('assistent_fertig'),
                  onPressed: _beschaeftigt ? null : _schliessen,
                  child: Text(l10n.jahresberichtAssistentSchliessen),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
