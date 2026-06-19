import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../router/router.dart';
import '../../view_model/eintrag/eintrag_viewmodel.dart';
import '../../view_model/eintrag/selected_eintrag_viewmodel.dart';
import '../list_detail/list_detail.dart';
import 'eintrag_form.dart';
import 'eintrag_widget.dart';
import 'pdf_export.dart';

class EintragScreen extends ConsumerWidget {
  final String? eintragId;
  const EintragScreen({super.key, this.eintragId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                subtitle: Text(
                  MaterialLocalizations.of(context).formatFullDate(e.start),
                ),
              ),
            )
            .toList();
        var index = eintragId != null
            ? eintrage.indexWhere((element) => element.id == eintragId)
            : null;
        if (index == -1) {
          index = null;
        }
        return ListDetailLayout(
          items: items,
          initialSelectedIndex: index,
          emptyDetail: const Center(
            child: Text(
              'Wähle einen Eintrag aus der Liste aus, um Details zu sehen.',
            ),
          ),
          actionsBuilder: (context, selectedIndex) {
            if (selectedIndex == null) return null;
            final eintragId = eintrage[selectedIndex].id;
            return [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () async {
                  final selectedEintrag = ref
                      .read(selectedEintragViewModelProvider(eintragId))
                      .value;
                  if (selectedEintrag == null) return;
                  await Printing.layoutPdf(
                    onLayout: (_) =>
                        generateEintragPdf(eintrag: selectedEintrag),
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
            return EintragDisplay(eintragId: selectedEintrag.id);
          },
        );
      },
    );
  }
}
