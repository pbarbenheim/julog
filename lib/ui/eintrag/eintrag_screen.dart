import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jlcore/jlcore.dart';
import 'package:printing/printing.dart';

import '../../router/router.dart';
import '../../view_model/eintrag/eintrag_viewmodel.dart';
import '../../view_model/eintrag/selected_eintrag_viewmodel.dart';
import '../list_detail/list_detail.dart';
import 'eintrag_form.dart';
import 'eintrag_widget.dart';
import 'pdf_export.dart';

class EintragScreen extends ConsumerStatefulWidget {
  final String? eintragId;
  const EintragScreen({super.key, this.eintragId});

  @override
  ConsumerState<EintragScreen> createState() => _EintragScreenState();
}

class _EintragScreenState extends ConsumerState<EintragScreen> {
  int? _selectedIndex;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
  }

  void _onSelectionChanged(int? index) {
    setState(() {
      _selectedIndex = index;
      _editMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eintragIdsValue = ref.watch(eintragViewModelProvider);
    return eintragIdsValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (eintrage) {
        eintrage.sort((a, b) => b.start.compareTo(a.start));
        final items = eintrage
            .map(
              (e) => ListItem(
                title: Text(e.thema),
                subtitle: Row(
                  children: [
                    Icon(
                      e.isSigned ? Icons.verified : Icons.edit,
                      size: 16,
                      color: e.isSigned ? null : Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      MaterialLocalizations.of(context).formatFullDate(e.start),
                    ),
                  ],
                ),
              ),
            )
            .toList();

        int? initialIndex = widget.eintragId != null
            ? eintrage.indexWhere((e) => e.id == widget.eintragId)
            : _selectedIndex;
        if (initialIndex == -1) initialIndex = null;

        return ListDetailLayout(
          items: items,
          initialSelectedIndex: initialIndex,
          onSelectionChanged: _onSelectionChanged,
          emptyDetail: const Center(
            child: Text(
              'Wähle einen Eintrag aus der Liste aus, um Details zu sehen.',
            ),
          ),
          actionsBuilder: (context, selectedIndex) {
            if (selectedIndex == null) return null;
            final eintragId = eintrage[selectedIndex].id;
            final eintragAsync = ref.watch(
              selectedEintragViewModelProvider(eintragId),
            );
            final selectedEintrag = eintragAsync.value;
            final isUnsigned =
                selectedEintrag != null && selectedEintrag.signatures.isEmpty;

            return [
              if (isUnsigned && !_editMode) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Eintrag bearbeiten',
                  onPressed: () => setState(() => _editMode = true),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Eintrag löschen',
                  onPressed: () =>
                      _confirmDelete(context, eintragId, selectedIndex),
                ),
              ],
              if (_editMode)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Bearbeitung abbrechen',
                  onPressed: () => setState(() => _editMode = false),
                ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () async {
                  final selected = ref
                      .read(selectedEintragViewModelProvider(eintragId))
                      .value;
                  if (selected == null) return;
                  await Printing.layoutPdf(
                    onLayout: (_) => generateEintragPdf(eintrag: selected),
                  );
                },
              ),
            ];
          },
          form: EintragForm(
            onSave:
                (
                  DateTime start,
                  DateTime end,
                  String kategorieId,
                  String thema,
                  String? ort,
                  String? raum,
                  String? dienstverlauf,
                  String? besonderheiten,
                  List<String> betreuerIds,
                  List<String> anwesendeJugendlicherIds,
                  List<String> entschuldigteJugendlicherIds,
                ) async {
                  final id = await ref
                      .read(eintragViewModelProvider.notifier)
                      .addEintrag(
                        start: start,
                        end: end,
                        kategorieId: kategorieId,
                        thema: thema,
                        ort: ort,
                        raum: raum,
                        dienstverlauf: dienstverlauf,
                        besonderheiten: besonderheiten,
                        betreuerIds: betreuerIds,
                        anwesendeJugendlicherIds: anwesendeJugendlicherIds,
                        entschuldigteJugendlicherIds:
                            entschuldigteJugendlicherIds,
                      );
                  if (!context.mounted) return;
                  EintragRoute(eintragId: id).go(context);
                },
          ),
          detailBuilder: (context, index) {
            final selectedEintrag = eintrage[index];
            if (_editMode) {
              final eintragAsync = ref.watch(
                selectedEintragViewModelProvider(selectedEintrag.id),
              );
              return eintragAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Fehler: $e')),
                data: (full) => EintragForm(
                  initialValues: EintragInitialValues(
                    start: full.start,
                    end: full.end,
                    kategorieId: full.kategorie.id,
                    thema: full.thema ?? '',
                    ort: full.ort,
                    raum: full.raum,
                    dienstverlauf: full.dienstverlauf,
                    besonderheiten: full.besonderheiten,
                    betreuerIds: full.betreuer.map((b) => b.id).toList(),
                    jugendliche: {
                      for (final j in full.anwesendeJugendliche)
                        j.id: Anwesenheit.anwesend,
                      for (final j in full.entschuldigteJugendliche)
                        j.id: Anwesenheit.entschuldigt,
                      for (final j in full.undefinierteJugendliche)
                        j.id: Anwesenheit.undefiniert,
                    },
                  ),
                  onSave:
                      (
                        DateTime start,
                        DateTime end,
                        String kategorieId,
                        String thema,
                        String? ort,
                        String? raum,
                        String? dienstverlauf,
                        String? besonderheiten,
                        List<String> betreuerIds,
                        List<String> anwesendeJugendlicherIds,
                        List<String> entschuldigteJugendlicherIds,
                      ) async {
                        final result = await ref
                            .read(
                              selectedEintragViewModelProvider(
                                selectedEintrag.id,
                              ).notifier,
                            )
                            .editEintrag(
                              start: start,
                              end: end,
                              kategorieId: kategorieId,
                              thema: thema,
                              ort: ort,
                              raum: raum,
                              dienstverlauf: dienstverlauf,
                              besonderheiten: besonderheiten,
                              betreuerIds: betreuerIds,
                              anwesendeJugendlicherIds:
                                  anwesendeJugendlicherIds,
                              entschuldigteJugendlicherIds:
                                  entschuldigteJugendlicherIds,
                            );
                        if (!context.mounted) return;
                        switch (result) {
                          case Success<Unit>():
                            setState(() => _editMode = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Eintrag erfolgreich gespeichert.',
                                ),
                              ),
                            );
                          case Failure<Unit>():
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Fehler beim Speichern: ${result.error}',
                                ),
                              ),
                            );
                        }
                      },
                ),
              );
            }
            return EintragDisplay(eintragId: selectedEintrag.id);
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String eintragId,
    int selectedIndex,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eintrag löschen'),
        content: const Text(
          'Dieser Eintrag wird unwiderruflich gelöscht. Fortfahren?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final result = await ref
        .read(selectedEintragViewModelProvider(eintragId).notifier)
        .delete();

    if (!context.mounted) return;
    switch (result) {
      case Success<Unit>():
        setState(() {
          _selectedIndex = null;
          _editMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eintrag wurde gelöscht.')),
        );
      case Failure<Unit>():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: ${result.error}')),
        );
    }
  }
}
