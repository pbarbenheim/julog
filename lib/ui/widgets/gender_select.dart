import 'package:flutter/material.dart';

import '../../repository/model/model.dart';
import 'radio_form_field.dart';

class GenderSelect extends StatelessWidget {
  final Gender? initialValue;
  final ValueChanged<Gender?>? onChanged;
  const GenderSelect({super.key, this.onChanged, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return RadioFormField<Gender?>(
      options: const [
        RadioFormFieldOption(label: 'Weiblich', value: Gender.female),
        RadioFormFieldOption(label: 'Männlich', value: Gender.male),
        RadioFormFieldOption(label: 'Divers', value: Gender.diverse),
      ],
      initialValue: initialValue,
      validator: (value) {
        if (value == null) {
          return 'Bitte wähle ein Geschlecht aus';
        }
        return null;
      },
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Geschlecht',
        border: InputBorder.none,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
