import 'package:flutter/material.dart';

import '../../repository/model/model.dart';

class AustrittDialog extends StatefulWidget {
  final Future<void> Function(DateTime exitDate, AustrittsGrund grund) onConfirm;

  const AustrittDialog({super.key, required this.onConfirm});

  @override
  State<AustrittDialog> createState() => _AustrittDialogState();
}

class _AustrittDialogState extends State<AustrittDialog> {
  DateTime? _exitDate;
  AustrittsGrund? _grund;
  bool _loading = false;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _exitDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _exitDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _exitDate != null && _grund != null && !_loading;

    return AlertDialog(
      title: const Text('Austritt erfassen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _exitDate == null
                  ? 'Austrittsdatum wählen'
                  : 'Austrittsdatum: ${_exitDate!.day}.${_exitDate!.month}.${_exitDate!.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(context),
          ),
          const SizedBox(height: 8),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Austrittsgrund'),
            child: DropdownButton<AustrittsGrund>(
              value: _grund,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: const Text('Bitte wählen'),
              items: AustrittsGrund.values
                  .map(
                    (g) => DropdownMenuItem(value: g, child: Text(g.display)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _grund = value),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: canSave
              ? () async {
                  setState(() => _loading = true);
                  await widget.onConfirm(_exitDate!, _grund!);
                  if (context.mounted) Navigator.of(context).pop();
                }
              : null,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Speichern'),
        ),
      ],
    );
  }
}
