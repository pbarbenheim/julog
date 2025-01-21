import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/repository.dart';
import '../frame.dart';
import '../routes.dart';
import '../widgets/betreuer.dart';

class BetreuerScreen extends ConsumerWidget {
  final int? selectedId;
  const BetreuerScreen({super.key, this.selectedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(repositoryProvider)!;

    final items = db.betreuerRepository
        .getAllBetreuer()
        .map((e) => BetreuerItem(
              name: e.name,
              id: e.id,
              geschlecht: e.geschlecht,
            ))
        .toList();
    BetreuerItem? selectedItem;
    try {
      selectedItem = items.firstWhere(
        (element) => element.id == selectedId,
      );
    } catch (e) {
      //Nothing to catch
    }
    return ListDetail(
      items: items,
      onChanged: (value) {
        BetreuerRoute(value.id).go(context);
      },
      listHeader: "Betreuer",
      destination: Destination.betreuer,
      selectedItem: selectedItem,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          const AddBetreuerRoute().go(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddBetreuerScreen extends StatelessWidget {
  const AddBetreuerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return JulogScaffold(
      body: const Center(child: AddBetreuerForm()),
      destination: Destination.betreuer,
      appBar: AppBar(
        title: const Text("Betreuer hinzufügen"),
      ),
    );
  }
}
