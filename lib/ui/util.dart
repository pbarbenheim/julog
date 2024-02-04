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
