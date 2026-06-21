import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/eintrag/eintrag_form_viewmodel.dart';
import '../widgets/datetime_picker.dart';

class EintragInitialValues {
  final DateTime start;
  final DateTime end;
  final String kategorieId;
  final String thema;
  final String? ort;
  final String? raum;
  final String? dienstverlauf;
  final String? besonderheiten;
  final List<String> betreuerIds;
  final Map<String, Anwesenheit> jugendliche;

  const EintragInitialValues({
    required this.start,
    required this.end,
    required this.kategorieId,
    required this.thema,
    this.ort,
    this.raum,
    this.dienstverlauf,
    this.besonderheiten,
    required this.betreuerIds,
    required this.jugendliche,
  });
}

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
  final EintragInitialValues? initialValues;

  const EintragForm({super.key, this.onSave, this.initialValues});

  @override
  ConsumerState<EintragForm> createState() => _EintragFormState();
}

class _EintragFormState extends ConsumerState<EintragForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _themaController;
  late final TextEditingController _ortController;
  late final TextEditingController _raumController;
  late final TextEditingController _dienstverlaufController;
  late final TextEditingController _besonderheitenController;

  DateTime? _start;
  DateTime? _end;
  String? _kategorieId;
  late List<String> _betreuerIds;
  late Map<String, Anwesenheit> _jugendliche;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final iv = widget.initialValues;
    _themaController = TextEditingController(text: iv?.thema ?? '');
    _ortController = TextEditingController(text: iv?.ort ?? '');
    _raumController = TextEditingController(text: iv?.raum ?? '');
    _dienstverlaufController = TextEditingController(
      text: iv?.dienstverlauf ?? '',
    );
    _besonderheitenController = TextEditingController(
      text: iv?.besonderheiten ?? '',
    );
    _start = iv?.start;
    _end = iv?.end;
    _kategorieId = iv?.kategorieId;
    _betreuerIds = List.of(iv?.betreuerIds ?? []);
    _jugendliche = Map.of(iv?.jugendliche ?? {});
  }

  @override
  void dispose() {
    _themaController.dispose();
    _ortController.dispose();
    _raumController.dispose();
    _dienstverlaufController.dispose();
    _besonderheitenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(eintragFormViewmodelProvider);
    final isEdit = widget.initialValues != null;
    return options.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Fehler: $error')),
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
                    isEdit ? 'Eintrag bearbeiten' : 'Neuen Eintrag hinzufügen',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  DateTimePickerFormField(
                    initialValue: _start,
                    labelText: 'Startzeit',
                    onSaved: (newValue) => _start = newValue,
                    onChanged: (value) {
                      _start = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Bitte Startzeit auswählen';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DateTimePickerFormField(
                    initialValue: _end,
                    labelText: 'Endzeit',
                    onSaved: (newValue) => _end = newValue,
                    validator: (value) {
                      if (value == null) {
                        return 'Bitte Endzeit auswählen';
                      }
                      if (_start != null &&
                          value.difference(_start!).isNegative) {
                        return 'Endzeit muss nach der Startzeit liegen';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownMenuFormField(
                    label: const Text('Kategorie'),
                    initialSelection: _kategorieId,
                    dropdownMenuEntries: kategorien.entries
                        .map(
                          (e) =>
                              DropdownMenuEntry(value: e.key, label: e.value),
                        )
                        .toList(),
                    onSaved: (newValue) => _kategorieId = newValue,
                    validator: (value) {
                      if (value == null) {
                        return 'Bitte Kategorie auswählen';
                      }
                      return null;
                    },
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.value,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            SegmentedButton<Anwesenheit>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: Anwesenheit.anwesend,
                                  label: Text('Anwesend'),
                                  icon: Icon(Icons.check),
                                ),
                                ButtonSegment(
                                  value: Anwesenheit.entschuldigt,
                                  label: Text('Entschuldigt'),
                                  icon: Icon(Icons.event_busy),
                                ),
                                ButtonSegment(
                                  value: Anwesenheit.undefiniert,
                                  label: Text('–'),
                                ),
                              ],
                              selected: {
                                _jugendliche[e.key] ?? Anwesenheit.undefiniert,
                              },
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _jugendliche[e.key] = selection.first;
                                });
                              },
                            ),
                          ],
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
                            try {
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
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _loading = false;
                                });
                              }
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

enum Anwesenheit { anwesend, entschuldigt, undefiniert }
