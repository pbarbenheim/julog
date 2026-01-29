import 'dart:async';

import 'package:flutter/material.dart';

import '../../repository/model/model.dart';
import '../widgets/gender_select.dart';

class BetreuerForm extends StatefulWidget {
  final FutureOr<void> Function(String name, Gender gender)? onSave;

  const BetreuerForm({super.key, this.onSave});

  @override
  State<BetreuerForm> createState() => _BetreuerFormState();
}

class _BetreuerFormState extends State<BetreuerForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  Gender? _selectedGender;

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Neuen Betreuer hinzufügen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib einen Namen ein';
                }
                return null;
              },
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            GenderSelect(
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onSave != null
                  ? () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loading = true;
                        });
                        await widget.onSave?.call(
                          _nameController.text,
                          _selectedGender!,
                        );
                        if (mounted) {
                          _loading = false;
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
    );
  }
}
