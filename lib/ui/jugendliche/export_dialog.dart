import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../repository/model/jugendliche/jugendlicher.dart';
import 'pdf_export.dart';

enum _SelectionMode { alle, auswahl }

class _ExportField {
  final String label;
  final bool alwaysOn;
  bool selected;

  _ExportField({
    required this.label,
    required this.alwaysOn,
    required this.selected,
  });
}

class _JugendlicheEntry {
  final Jugendlicher jugendlicher;
  final bool isAktiv;
  bool selected;

  _JugendlicheEntry({
    required this.jugendlicher,
    required this.isAktiv,
    required this.selected,
  });
}

class JugendlicheExportDialog extends StatefulWidget {
  final List<Jugendlicher> jugendliche;

  const JugendlicheExportDialog({super.key, required this.jugendliche});

  @override
  State<JugendlicheExportDialog> createState() =>
      _JugendlicheExportDialogState();
}

class _JugendlicheExportDialogState extends State<JugendlicheExportDialog> {
  final _titleController = TextEditingController();
  late final List<_ExportField> _fields;
  late final List<_JugendlicheEntry> _jugendlicheEntries;
  late final DateTime _today;
  _SelectionMode _selectionMode = _SelectionMode.alle;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _fields = [
      _ExportField(label: 'Name', alwaysOn: true, selected: true),
      _ExportField(label: 'Passnummer', alwaysOn: false, selected: true),
      _ExportField(label: 'Geburtsdatum', alwaysOn: false, selected: true),
      _ExportField(label: 'Geschlecht', alwaysOn: false, selected: false),
      _ExportField(label: 'Mitglied seit', alwaysOn: false, selected: false),
      _ExportField(label: 'Austrittsdatum', alwaysOn: false, selected: false),
      _ExportField(label: 'Austrittsgrund', alwaysOn: false, selected: false),
      _ExportField(label: 'Unterschrift', alwaysOn: false, selected: false),
    ];
    _jugendlicheEntries = widget.jugendliche.map((j) {
      final isAktiv = !j.isAusgetreten(_today);
      return _JugendlicheEntry(
        jugendlicher: j,
        isAktiv: isAktiv,
        selected: isAktiv,
      );
    }).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final selectedFields = _fields
        .where((f) => f.selected)
        .map((f) => f.label)
        .toList();
    final jugendlicheToExport = switch (_selectionMode) {
      _SelectionMode.alle =>
        widget.jugendliche.where((j) => !j.isAusgetreten(_today)).toList(),
      _SelectionMode.auswahl =>
        _jugendlicheEntries
            .where((e) => e.selected)
            .map((e) => e.jugendlicher)
            .toList(),
    };
    final pdfBytes = await generateJugendlichePdf(
      title: _titleController.text,
      exportDate: DateTime.now(),
      jugendliche: jugendlicheToExport,
      selectedFields: selectedFields,
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    await Printing.layoutPdf(
      onLayout: (_) => Future.value(pdfBytes),
      name: _titleController.text.isEmpty
          ? 'Jugendliche'
          : _titleController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('PDF exportieren'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  hintText: 'z.B. Zeltlager 2026',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Jugendliche:'),
              const SizedBox(height: 8),
              SegmentedButton<_SelectionMode>(
                segments: const [
                  ButtonSegment(
                    value: _SelectionMode.alle,
                    label: Text('Alle'),
                  ),
                  ButtonSegment(
                    value: _SelectionMode.auswahl,
                    label: Text('Auswahl'),
                  ),
                ],
                selected: {_selectionMode},
                onSelectionChanged: (value) =>
                    setState(() => _selectionMode = value.first),
              ),
              if (_selectionMode == _SelectionMode.auswahl) ...[
                const SizedBox(height: 8),
                ..._jugendlicheEntries.map(
                  (entry) => CheckboxListTile(
                    title: Text(
                      entry.jugendlicher.name,
                      style: entry.isAktiv
                          ? null
                          : TextStyle(color: Theme.of(context).disabledColor),
                    ),
                    value: entry.selected,
                    onChanged: (value) =>
                        setState(() => entry.selected = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Felder auswählen:'),
              const SizedBox(height: 8),
              ..._fields.map(
                (field) => CheckboxListTile(
                  title: Text(field.label),
                  value: field.selected,
                  onChanged: field.alwaysOn
                      ? null
                      : (value) =>
                            setState(() => field.selected = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(onPressed: _export, child: const Text('Exportieren')),
      ],
    );
  }
}
