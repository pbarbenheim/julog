import 'package:dienstbuch/repository/repository.dart';
import 'package:dienstbuch/ui/frame.dart';
import 'package:dienstbuch/ui/routes.dart';
import 'package:dienstbuch/ui/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JugendlicheScreen extends ConsumerWidget {
  final int? id;
  const JugendlicheScreen({super.key, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref
        .watch(repositoryProvider.select((value) => value!.getAllJugendliche()))
        .entries
        .map((e) => JugendlicheItem(
              id: e.key,
              name: e.value,
              ref: ref,
            ))
        .toList();

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

class JugendlicheItem extends Item {
  final int id;
  final String name;
  final WidgetRef ref;

  const JugendlicheItem({
    super.key,
    required this.id,
    required this.name,
    required this.ref,
  }) : super(title: name);

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final ju = repo!.getJugendlicher(id);

    return Column(
      children: [
        Text("ID: ${ju.id}"),
        Text("Name: ${ju.name}"),
        Text("Geschlecht: ${ju.geschlecht}"),
        Text("Passnummer: ${ju.passnummer ?? '-'}"),
        Text("Geburtstag: ${ju.geburtstag}"),
        Text("Eintrittsdatum: ${ju.eintrittsdatum}"),
        Text("Austrittsdatum: ${ju.austrittsdatum ?? '-'}"),
        Text("Austrittsgrund: ${ju.austrittsgrund ?? '-'}"),
      ],
    );
  }
}

class AddJugendlicheScreen extends StatelessWidget {
  const AddJugendlicheScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DienstbuchScaffold(
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

class AddJugendlicheForm extends ConsumerStatefulWidget {
  const AddJugendlicheForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddJugendlicheFormState();
}

class _AddJugendlicheFormState extends ConsumerState<AddJugendlicheForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _passnummerController;
  final GlobalKey<FormFieldState<DateTime>> _geburtstagKey =
      GlobalKey<FormFieldState<DateTime>>();
  final GlobalKey<FormFieldState<DateTime>> _eintrittKey =
      GlobalKey<FormFieldState<DateTime>>();
  Geschlecht? _geschlecht;

  @override
  void initState() {
    _passnummerController = TextEditingController();
    _nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passnummerController.dispose();
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
              hintText: "Name des Jugendlichen",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Der Name kann nicht leer sein.";
              }
              if (!Repository.checkString(value)) {
                return "Der Name enthält verbotene Zeichen.";
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
          TextFormField(
            controller: _passnummerController,
            decoration: const InputDecoration(
              labelText: "Passnummer",
              hintText:
                  "Passnummer des Jugendlichen auf dem Pass der Deutschen Jugendfeuerwehr",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (!Repository.checkString(value ?? "")) {
                return "Die Passnummer enthält verbotene Zeichen.";
              }
              return null;
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          FormField<DateTime>(
            key: _geburtstagKey,
            builder: (field) {
              return Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        lastDate: DateTime.now()
                            .subtract(const Duration(days: 360 * 8)),
                        firstDate: DateTime(2000),
                        helpText: "Geburtstag auswählen",
                        cancelText: "Abbrechen",
                        confirmText: "OK",
                      );
                      field.didChange(date);
                    },
                    child: const Text("Geburtstag auswählen"),
                  ),
                  Text(field.value?.toString() ?? "-"),
                  if (field.errorText != null)
                    Text(
                      field.errorText!,
                      style: const TextStyle(color: Colors.redAccent),
                    )
                ],
              );
            },
            validator: (value) {
              if (value == null) {
                return "Es muss ein Geburtsdatum ausgewählt werden";
              }
              return null;
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          FormField<DateTime>(
            key: _eintrittKey,
            builder: (field) {
              return Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        lastDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        helpText: "Eintrittsdatum auswählen",
                        cancelText: "Abbrechen",
                        confirmText: "OK",
                      );
                      field.didChange(date);
                    },
                    child: const Text("Eintrittsdatum auswählen"),
                  ),
                  Text(field.value?.toString() ?? "-"),
                  if (field.errorText != null)
                    Text(
                      field.errorText!,
                      style: const TextStyle(color: Colors.redAccent),
                    )
                ],
              );
            },
            validator: (value) {
              if (value == null) {
                return "Es muss ein Eintrittsdatum ausgewählt werden";
              }
              return null;
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final repo = ref.read(repositoryProvider)!;
                String? passnummer;
                if (_passnummerController.text.isNotEmpty) {
                  passnummer = _passnummerController.text;
                }
                final id = repo.addJugendlicher(
                    name: _nameController.text,
                    geburtstag: _geburtstagKey.currentState!.value!,
                    eintrittsdatum: _eintrittKey.currentState!.value!,
                    passnummer: passnummer,
                    geschlecht: _geschlecht!);
                if (mounted) {
                  JugendlicheRoute(id).go(context);
                }
              }
            },
            child: const Text("Erstellen"),
          ),
        ],
      ),
    );
  }
}
