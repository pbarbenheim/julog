import 'package:flutter/material.dart';

import '../../repository/model/model.dart';
import 'radio_form_field.dart';

class HerkunftSelect extends StatelessWidget {
  final Herkunft initialValue;
  final ValueChanged<Herkunft?>? onChanged;
  const HerkunftSelect({
    super.key,
    this.onChanged,
    this.initialValue = Herkunft.neu,
  });

  @override
  Widget build(BuildContext context) {
    return RadioFormField<Herkunft?>(
      options: [
        for (final herkunft in Herkunft.values)
          RadioFormFieldOption(label: herkunft.display, value: herkunft),
      ],
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Herkunft',
        border: InputBorder.none,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
