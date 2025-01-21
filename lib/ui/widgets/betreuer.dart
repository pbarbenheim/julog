import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:julog/repository/util/geschlecht.dart';
import 'package:julog/repository/util/util.dart';

import '../../repository/repository.dart';
import '../frame.dart';
import '../routes.dart';
import 'util.dart';

class BetreuerItem extends Item {
  final String name;
  final int id;
  final Geschlecht geschlecht;
  BetreuerItem({
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
              if (!Util.checkString(value)) {
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
                    .betreuerRepository
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
