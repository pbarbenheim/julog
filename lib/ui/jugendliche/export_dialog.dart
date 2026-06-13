import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../repository/model/jugendliche/jugendlicher.dart';
import 'pdf_export.dart';

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

  @override
  void initState() {
    super.initState();
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
    final pdfBytes = await generateJugendlichePdf(
      title: _titleController.text,
      exportDate: DateTime.now(),
      jugendliche: widget.jugendliche,
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
