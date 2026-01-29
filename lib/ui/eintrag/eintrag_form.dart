import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/eintrag/eintrag_form_viewmodel.dart';
import '../widgets/datetime_picker.dart';

class EintragForm extends ConsumerStatefulWidget {
  final FutureOr<void> Function(
    DateTime start,
    DateTime end,
    String kategorieId,
    String thema,
    String? ort,
    String? raum,
    String? dienstverlauf,
    String? besonderheiten,
    List<String> betreuerIds,
    List<String> anwesendeJugendlicherIds,
    List<String> entschuldigteJugendlicherIds,
  )?
  onSave;
  const EintragForm({super.key, this.onSave});

  @override
  ConsumerState<EintragForm> createState() => _EintragFormState();
}

enum Anwesenheit { anwesend, entschuldigt, undefiniert }

class _EintragFormState extends ConsumerState<EintragForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _themaController = TextEditingController();
  final TextEditingController _ortController = TextEditingController();
  final TextEditingController _raumController = TextEditingController();
  final TextEditingController _dienstverlaufController =
      TextEditingController();
  final TextEditingController _besonderheitenController =
      TextEditingController();

  DateTime? _start;
  DateTime? _end;
  String? _kategorieId;
  final List<String> _betreuerIds = [];
  final Map<String, Anwesenheit> _jugendliche = {};

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(eintragFormViewmodelProvider);
    return options.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (data) {
        final betreuer = data.betreuerOptions;
        final jugendliche = data.jugendlicheOptions;
        final kategorien = data.kategorieOptions;
        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Eintrag Form',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  DateTimePickerFormField(
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 2)),
                    labelText: 'Startzeit',
                    onSaved: (newValue) => _start = newValue,
                    validator: (value) {
                      if (value == null) {
                        return 'Bitte Startzeit auswählen';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DateTimePickerFormField(
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 30),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 2)),
                    labelText: 'Endzeit',
                    onSaved: (newValue) => _end = newValue,
                    validator: (value) {
                      if (value == null) {
                        return 'Bitte Endzeit auswählen';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownMenuFormField(
                    label: const Text('Kategorie'),
                    dropdownMenuEntries: kategorien.entries
                        .map(
                          (e) =>
                              DropdownMenuEntry(value: e.key, label: e.value),
                        )
                        .toList(),
                    onSaved: (newValue) => _kategorieId = newValue,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Thema'),
                    controller: _themaController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte Thema eingeben';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Ort'),
                    controller: _ortController,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Raum'),
                    controller: _raumController,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Dienstverlauf',
                    ),
                    controller: _dienstverlaufController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Besonderheiten',
                    ),
                    controller: _besonderheitenController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Betreuer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: betreuer.entries
                        .map<Widget>(
                          (MapEntry<String, String> e) {
                                final isSelected = _betreuerIds.contains(e.key);
                                return FilterChip(
                                  label: Text(e.value),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _betreuerIds.add(e.key);
                                      } else {
                                        _betreuerIds.remove(e.key);
                                      }
                                    });
                                  },
                                );
                              }
                              as Widget Function(MapEntry<String, String> e),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Jugendliche',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: jugendliche.entries.map((e) {
                      return ListTile(
                        title: Text(e.value),
                        leading: IconButton(
                          onPressed: () {
                            setState(() {
                              final current = _jugendliche[e.key];
                              if (current == Anwesenheit.anwesend) {
                                _jugendliche[e.key] = Anwesenheit.entschuldigt;
                              } else if (current == Anwesenheit.entschuldigt) {
                                _jugendliche[e.key] = Anwesenheit.undefiniert;
                              } else {
                                _jugendliche[e.key] = Anwesenheit.anwesend;
                              }
                            });
                          },
                          icon: _jugendliche[e.key] == Anwesenheit.anwesend
                              ? const Icon(Icons.check_box)
                              : _jugendliche[e.key] == Anwesenheit.entschuldigt
                              ? const Icon(Icons.check_box_outline_blank)
                              : const Icon(Icons.indeterminate_check_box),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.onSave != null
                        ? () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                            setState(() {
                              _loading = true;
                            });
                            _formKey.currentState!.save();

                            final anwesendeIds = _jugendliche.entries
                                .where((e) => e.value == Anwesenheit.anwesend)
                                .map((e) => e.key)
                                .toList();
                            final entschuldigteIds = _jugendliche.entries
                                .where(
                                  (e) => e.value == Anwesenheit.entschuldigt,
                                )
                                .map((e) => e.key)
                                .toList();
                            await widget.onSave!(
                              _start!,
                              _end!,
                              _kategorieId!,
                              _themaController.text,
                              _ortController.text.isEmpty
                                  ? null
                                  : _ortController.text,
                              _raumController.text.isEmpty
                                  ? null
                                  : _raumController.text,
                              _dienstverlaufController.text.isEmpty
                                  ? null
                                  : _dienstverlaufController.text,
                              _besonderheitenController.text.isEmpty
                                  ? null
                                  : _besonderheitenController.text,
                              _betreuerIds,
                              anwesendeIds,
                              entschuldigteIds,
                            );
                            if (mounted) {
                              setState(() {
                                _loading = false;
                              });
                            }
                          }
                        : null,
                    child: const Text('Speichern'),
                  ),
                  if (_loading) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
