import 'package:dienstbuch/repository/repository.dart';
import 'package:dienstbuch/ui/frame.dart';
import 'package:dienstbuch/ui/routes.dart';
import 'package:dienstbuch/ui/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BetreuerScreen extends ConsumerWidget {
  final int? selectedId;
  const BetreuerScreen({super.key, this.selectedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = (ref.watch(repositoryProvider
                .select((value) => value?.getAllBetreuer())) ??
            [])
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

class BetreuerItem extends Item {
  final String name;
  final int id;
  final Geschlecht geschlecht;
  const BetreuerItem({
    required this.geschlecht,
    super.key,
    required this.name,
    required this.id,
  }) : super(title: name);

  @override
  Widget build(BuildContext context) {
    return Text("$name ($geschlecht, $id)");
  }
}

class AddBetreuerScreen extends StatelessWidget {
  const AddBetreuerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DienstbuchScaffold(
      body: const Center(child: AddBetreuerForm()),
      destination: Destination.betreuer,
      appBar: AppBar(
        title: const Text("Betreuer hinzufügen"),
      ),
    );
  }
}

class AddBetreuerForm extends ConsumerStatefulWidget {
  const AddBetreuerForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddBetreuerFormState();
}

class _AddBetreuerFormState extends ConsumerState<AddBetreuerForm> {
  late final TextEditingController _nameController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Geschlecht? _geschlecht;

  @override
  void initState() {
    _nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Name",
              hintText: "Name des Betreuers",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Der Name darf nicht leer sein";
              }
              if (!Repository.checkString(value)) {
                return "Der Name enthält verbotene Zeichen";
              }
              return null;
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          GeschlechtDropDown(
            onChanged: (value) {
              setState(() {
                _geschlecht = value;
              });
            },
            value: _geschlecht,
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final betreuer = ref
                    .read(repositoryProvider)!
                    .addBetreuer(_nameController.text, _geschlecht!);
                BetreuerRoute(betreuer.id).go(context);
              }
            },
            child: const Text("Erstellen"),
          ),
        ],
      ),
    );
  }
}
