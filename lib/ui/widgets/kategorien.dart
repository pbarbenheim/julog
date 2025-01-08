import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/repository.dart';
import '../frame.dart';
import '../routes.dart';

class KategorieItem extends Item {
  final Kategorie kategorie;
  KategorieItem({super.key, required this.kategorie})
      : super(title: kategorie.name);

  int get id => kategorie.id;
  String get name => kategorie.name;

  @override
  Widget build(BuildContext context) {
    return Text("Kategorie $name ($id)");
  }
}

class AddKategorieForm extends ConsumerStatefulWidget {
  const AddKategorieForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddKategorieFormState();
}

class _AddKategorieFormState extends ConsumerState<AddKategorieForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

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
              hintText: "Name der Kategorie",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Der Name muss angegeben werden.";
              }
              if (!Repository.checkString(value)) {
                return "Der Name enthält verbotene Zeichen.";
              }
              return null;
            },
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final kat = ref
                    .read(repositoryProvider)!
                    .addKategorie(_nameController.text);
                KategorienRoute(kat.id).go(context);
              }
            },
            child: const Text("Erstellen"),
          ),
        ],
      ),
    );
  }
}
