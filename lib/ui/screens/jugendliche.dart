import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/repository.dart';
import '../frame.dart';
import '../routes.dart';
import '../widgets/jugendliche.dart';

class JugendlicheScreen extends ConsumerWidget {
  final int? id;
  const JugendlicheScreen({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(repositoryProvider)!;
    final items = db.jugendlicherRepository
        .getAllJugendliche()
        .map((e) => JugendlicheItem(
              id: e.id,
              name: e.name,
              ref: ref,
            ))
        .toList();
    //TODO add filter to exclude ersetzte und inaktive

    JugendlicheItem? selectedItem;
    try {
      selectedItem = items.firstWhere((element) => element.id == id);
    } catch (e) {
      // Nothing to catch
    }

    return ListDetail<JugendlicheItem>(
      items: items,
      onChanged: (value) {
        JugendlicheRoute(value.id).go(context);
      },
      listHeader: "Jugendliche",
      destination: Destination.jugendliche,
      selectedItem: selectedItem,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          const AddJugendlicheRoute().go(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddJugendlicheScreen extends StatelessWidget {
  const AddJugendlicheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return JulogScaffold(
      body: const Center(
        child: AddJugendlicheForm(),
      ),
      destination: Destination.jugendliche,
      appBar: AppBar(
        title: const Text("Jugendlichen hinzufüguen"),
      ),
    );
  }
}
