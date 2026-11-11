import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../router/router.dart';
import '../../view_model/kategorie/kategorie.dart';
import '../list_detail/list_detail.dart';
import 'kategorie_form.dart';

class KategorieScreen extends ConsumerStatefulWidget {
  final String? kategorieId;
  const KategorieScreen({super.key, this.kategorieId});

  @override
  ConsumerState<KategorieScreen> createState() => _KategorieScreenState();
}

class _KategorieScreenState extends ConsumerState<KategorieScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final kategorieValue = ref.watch(kategorieViewModelProvider);
    return kategorieValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (kategorien) {
        kategorien.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        final items = kategorien
            .map((e) => ListItem(title: Text(e.name)))
            .toList();
        var index = widget.kategorieId != null
            ? kategorien.indexWhere(
                (element) => element.id == widget.kategorieId,
              )
            : null;
        if (index == -1) {
          index = null;
        }
        return ListDetailLayout(
          items: items,
          initialSelectedIndex: index,
          emptyDetail: const Center(
            child: Text(
              'Wähle eine Kategorie aus der Liste aus, um Details zu sehen.',
            ),
          ),
          form: KategorieForm(
            onSave: (name, berichtsthema) async {
              final id = await ref
                  .read(kategorieViewModelProvider.notifier)
                  .addKategorie(name, berichtsthema: berichtsthema);

              if (!context.mounted) return;
              KategorieRoute(kategorieId: id).go(context);
            },
          ),
          actionsBuilder: (context, selectedIndex) {
            if (selectedIndex == null) return null;
            if (_isEditing) {
              return [
                IconButton(
                  tooltip: 'Bearbeitung abbrechen',
                  onPressed: () => setState(() => _isEditing = false),
                  icon: const Icon(Icons.close),
                ),
              ];
            }
            return [
              IconButton(
                tooltip: 'Bearbeiten',
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit),
              ),
            ];
          },
          detailBuilder: (context, index) {
            final selectedKategorie = kategorien[index];
            final l10n = AppLocalizations.of(context)!;

            if (_isEditing) {
              final gesperrt = ref.watch(
                kategorieNameGesperrtProvider(selectedKategorie.id),
              );
              if (gesperrt.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return KategorieForm(
                key: ValueKey(selectedKategorie.id),
                initialKategorie: selectedKategorie,
                nameGesperrt: gesperrt.value ?? false,
                onSave: (name, berichtsthema) async {
                  await ref
                      .read(kategorieViewModelProvider.notifier)
                      .editKategorie(
                        id: selectedKategorie.id,
                        name: name,
                        berichtsthema: berichtsthema,
                      );
                  if (!context.mounted) return;
                  setState(() => _isEditing = false);
                },
              );
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedKategorie.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.stateBerichtsthema(
                        selectedKategorie.berichtsthema?.display ??
                            l10n.berichtsthemaNotAssigned,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('ID: ${selectedKategorie.id}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
