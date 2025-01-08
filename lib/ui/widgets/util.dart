import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../pubspec.g.dart';
import '../../repository/repository.dart';
import 'logo.dart';

void showJulogAbout({
  required BuildContext context,
  Offset? anchorPoint,
}) {
  return showAboutDialog(
    context: context,
    anchorPoint: anchorPoint,
    applicationName: "Julog",
    applicationVersion: Pubspec.version,
    applicationLegalese: "© Paul Barbenheim 2024",
    applicationIcon: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 80),
      child: const JulogLogo(),
    ),
  );
}

class GeschlechtDropDown extends StatelessWidget {
  final Geschlecht? value;
  final ValueChanged<Geschlecht?> onChanged;
  const GeschlechtDropDown({super.key, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Geschlecht>(
      items: const [
        DropdownMenuItem(
          value: Geschlecht.maennlich,
          child: Text("Männlich"),
        ),
        DropdownMenuItem(
          value: Geschlecht.weiblich,
          child: Text("Weiblich"),
        ),
        DropdownMenuItem(
          value: Geschlecht.divers,
          child: Text("Divers"),
        ),
      ],
      onChanged: onChanged,
      value: value,
      decoration: const InputDecoration(
        labelText: "Geschlecht",
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null) {
          return "Es muss ein Geschlecht ausgewählt werden.";
        }
        return null;
      },
    );
  }
}

class DateTimeField extends StatelessWidget {
  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final String labelText;
  final FormFieldValidator<DateTime?>? validator;
  const DateTimeField({
    super.key,
    this.initialValue,
    required this.onChanged,
    required this.labelText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime?>(
      builder: (field) {
        return Row(
          children: [
            Text(labelText),
            const Padding(padding: EdgeInsets.only(left: 5)),
            TextButton.icon(
              onPressed: () async {
                final dateTime = await showOmniDateTimePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  is24HourMode: true,
                  isShowSeconds: false,
                  minutesInterval: 1,
                  barrierDismissible: true,
                  lastDate: DateTime.now(),
                );

                field.didChange(dateTime);
                onChanged(dateTime);
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(field.value?.toString() ?? "Datum auswählen"),
            ),
          ],
        );
      },
      initialValue: initialValue,
      validator: validator,
    );
  }
}
