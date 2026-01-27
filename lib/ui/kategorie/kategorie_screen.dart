import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../router/router.dart';
import '../../view_model/kategorie/kategorie.dart';
import '../list_detail/list_detail.dart';
import 'kategorie_form.dart';

class KategorieScreen extends ConsumerWidget {
  final String? kategorieId;
  const KategorieScreen({super.key, this.kategorieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        var index = kategorieId != null
            ? kategorien.indexWhere((element) => element.id == kategorieId)
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
            onSave: (name) async {
              final id = await ref
                  .read(kategorieViewModelProvider.notifier)
                  .addKategorie(name);

              if (!context.mounted) return;
              KategorieRoute(kategorieId: id).go(context);
            },
          ),
          detailBuilder: (context, index) {
            final selectedKategorie = kategorien[index];
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
