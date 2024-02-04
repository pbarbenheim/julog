import 'package:dienstbuch/repository/repository.dart';
import 'package:flutter/material.dart';

void showDienstbuchAbout({
  required BuildContext context,
  Offset? anchorPoint,
}) {
  return showAboutDialog(
    context: context,
    anchorPoint: anchorPoint,
    applicationName: "Dienstbuch",
    applicationVersion: "1.0.0",
    applicationLegalese: "© Paul Barbenheim 2024",
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
