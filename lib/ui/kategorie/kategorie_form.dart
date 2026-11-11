import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../repository/model/model.dart';

class KategorieForm extends StatefulWidget {
  final FutureOr<void> Function(String name, Berichtsthema? berichtsthema)?
  onSave;
  final Kategorie? initialKategorie;

  const KategorieForm({super.key, this.onSave, this.initialKategorie});

  @override
  State<KategorieForm> createState() => _KategorieFormState();
}

class _KategorieFormState extends State<KategorieForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  Berichtsthema? _berichtsthema;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialKategorie;
    if (initial != null) {
      _nameController.text = initial.name;
      _berichtsthema = initial.berichtsthema;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              widget.initialKategorie != null
                  ? l10n.editKategorie
                  : l10n.addNewKategorie,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: l10n.name(1)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.kategorieNameRequired;
                }
                return null;
              },
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Berichtsthema?>(
              key: const Key('berichtsthema_field'),
              initialValue: _berichtsthema,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.berichtsthema),
              items: [
                DropdownMenuItem<Berichtsthema?>(
                  value: null,
                  child: Text(l10n.berichtsthemaNotAssigned),
                ),
                for (final thema in Berichtsthema.values)
                  DropdownMenuItem<Berichtsthema?>(
                    value: thema,
                    child: Text(thema.display),
                  ),
              ],
              onChanged: (value) => _berichtsthema = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loading = true;
                        });
                        await widget.onSave?.call(
                          _nameController.text,
                          _berichtsthema,
                        );
                        if (mounted) {
                          setState(() {
                            _loading = false;
                          });
                        }
                      }
                    },
              child: Text(l10n.saveButton),
            ),
            if (_loading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
