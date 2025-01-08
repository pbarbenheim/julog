import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/repository.dart';
import '../frame.dart';
import '../routes.dart';
import '../widgets/kategorien.dart';

class KategorienScreen extends ConsumerWidget {
  final int? id;
  const KategorienScreen({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref
        .watch(repositoryProvider.select((value) => value!.getAllKategorien()))
        .map((e) => KategorieItem(kategorie: e))
        .toList();
    KategorieItem? selectedItem;
    try {
      selectedItem = items.firstWhere((element) => element.id == id);
    } catch (e) {
      // Nothing to catch
    }

    return ListDetail(
      destination: Destination.kategorien,
      items: items,
      listHeader: "Kategorien",
      selectedItem: selectedItem,
      onChanged: (value) {
        KategorienRoute(value.id).go(context);
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          const AddKategorienRoute().go(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddKategorieScreen extends StatelessWidget {
  const AddKategorieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return JulogScaffold(
      destination: Destination.kategorien,
      appBar: AppBar(
        title: const Text("Kategorie hinzufügen"),
      ),
      body: const AddKategorieForm(),
    );
  }
}
