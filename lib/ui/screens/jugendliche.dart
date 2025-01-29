import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/repository.dart';
import '../frame.dart';
import '../routes.dart';
import '../widgets/jugendliche.dart';

enum JugendlicheFilter {
  inactive,
  replaced;
}

class JugendlicheScreen extends ConsumerStatefulWidget {
  final int? id;
  const JugendlicheScreen({super.key, this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _JugendlicheScreenState();
}

class _JugendlicheScreenState extends ConsumerState<JugendlicheScreen> {
  final Set<JugendlicheFilter> filters = <JugendlicheFilter>{};

  @override
  Widget build(BuildContext context) {
    final onlyActive = !filters.contains(JugendlicheFilter.inactive);
    final excludeReplaced = !filters.contains(JugendlicheFilter.replaced);
    final db = ref.watch(repositoryProvider)!;
    final items = db.jugendlicherRepository
        .getAllJugendliche(
          excludeReplaced: excludeReplaced,
          onlyActive: onlyActive,
        )
        .map((e) => JugendlicheItem(
              id: e.id,
              name: e.name,
              ref: ref,
            ))
        .toList();

    JugendlicheItem? selectedItem;
    try {
      selectedItem = items.firstWhere((element) => element.id == widget.id);
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
      filterChips: JugendlicheFilter.values.map((f) {
        return FilterChip(
          label: Text(f.name),
          selected: filters.contains(f),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                filters.add(f);
              } else {
                filters.remove(f);
              }
            });
          },
        );
      }).toList(),
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
