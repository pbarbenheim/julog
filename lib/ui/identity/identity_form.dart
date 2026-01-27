import 'dart:async';

import 'package:flutter/material.dart';

class IdentityForm extends StatefulWidget {
  final FutureOr<void> Function(
    String name,
    String function,
    String mail,
    String password,
  )?
  onSave;

  const IdentityForm({super.key, this.onSave});

  @override
  State<IdentityForm> createState() => _IdentityFormState();
}

class _IdentityFormState extends State<IdentityForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _functionController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _functionController.dispose();
    _mailController.dispose();
    _passController.dispose();
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
              'Neue Identität hinzufügen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib einen Namen ein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _functionController,
              decoration: const InputDecoration(labelText: 'Funktion'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib eine Funktion ein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _mailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib eine E-Mail ein.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Passwort'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib ein Passwort ein.';
                }
                return null;
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
                          _functionController.text,
                          _mailController.text,
                          _passController.text,
                        );

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
            // Additional form fields for function, mail, and password would go here
          ],
        ),
      ),
    );
  }
}
