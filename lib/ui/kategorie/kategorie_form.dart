import 'dart:async';

import 'package:flutter/material.dart';

class KategorieForm extends StatefulWidget {
  final FutureOr<void> Function(String name)? onSave;

  const KategorieForm({super.key, this.onSave});

  @override
  State<KategorieForm> createState() => _KategorieFormState();
}

class _KategorieFormState extends State<KategorieForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

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
              'Neue Kategorie hinzufügen',
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
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loading = true;
                        });
                        await widget.onSave?.call(_nameController.text);
                        if (mounted) {
                          setState(() {
                            _loading = false;
                          });
                        }
                      }
                    },
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
