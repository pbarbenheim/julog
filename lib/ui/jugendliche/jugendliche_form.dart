import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../repository/model/model.dart';
import '../widgets/gender_select.dart';

class JugendlicherForm extends StatefulWidget {
  final FutureOr<void> Function(
    String name,
    Gender gender,
    DateTime birthDate,
    DateTime memberSince,
    String? pass,
  )?
  onSave;

  const JugendlicherForm({super.key, this.onSave});

  @override
  State<JugendlicherForm> createState() => _JugendlicherFormState();
}

class _JugendlicherFormState extends State<JugendlicherForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  Gender? _selectedGender;
  DateTime? _birthDate;
  DateTime? _memberSince;
  final TextEditingController _passController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
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
              AppLocalizations.of(context)!.addNewJugendlicher,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name(1),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.nameRequired;
                }
                return null;
              },
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            GenderSelect(
              initialValue: _selectedGender,
              onChanged: (value) {
                _selectedGender = value;
              },
            ),
            const SizedBox(height: 16),
            InputDatePickerFormField(
              initialDate: _birthDate,
              firstDate: DateTime.now().subtract(
                const Duration(days: 365 * 27), // 27 years ago
              ),
              lastDate: DateTime.now().subtract(
                const Duration(days: 365 * 3), // 3 years ago
              ),
              fieldLabelText: AppLocalizations.of(context)!.birthdate,
              onDateSaved: (date) {
                _birthDate = date;
              },
              acceptEmptyDate: false,

              errorFormatText: AppLocalizations.of(context)!.dateFormatError,
              errorInvalidText: AppLocalizations.of(context)!.dateInvalidError,
            ),
            const SizedBox(height: 16),
            InputDatePickerFormField(
              initialDate: _memberSince,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              fieldLabelText: AppLocalizations.of(context)!.memberSince,
              onDateSaved: (date) {
                _memberSince = date;
              },
              acceptEmptyDate: false,
              errorFormatText: AppLocalizations.of(context)!.dateFormatError,
              errorInvalidText: AppLocalizations.of(context)!.dateInvalidError,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.optionalPass,
              ),
              controller: _passController,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onSave != null
                  ? () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setState(() {
                          _loading = true;
                        });
                        await widget.onSave?.call(
                          _nameController.text,
                          _selectedGender!,
                          _birthDate!,
                          _memberSince!,
                          _passController.text.isEmpty
                              ? null
                              : _passController.text,
                        );
                        if (mounted) {
                          setState(() {
                            _loading = false;
                          });
                        }
                      }
                    }
                  : null,
              child: Text(AppLocalizations.of(context)!.saveButton),
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
