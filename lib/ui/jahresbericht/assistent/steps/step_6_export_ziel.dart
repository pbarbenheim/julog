import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fragt den Anwender, wohin der Jahresbericht geschrieben werden soll.
///
/// Bekommt den vorgeschlagenen Dateinamen und liefert den gewählten Pfad,
/// oder `null`, wenn der Anwender abbricht.
typedef ExportZielWaehler =
    Future<String?> Function(String vorgeschlagenerName);

/// Die Auswahl des Exportziels. Standard ist der Speichern-Dialog des
/// Betriebssystems mit dem vom System vorgeschlagenen Ordner. Tests und
/// Treiber ersetzen sie, weil sich native Dialoge dort nicht bedienen
/// lassen.
final jahresberichtExportZielProvider = Provider<ExportZielWaehler>(
  (ref) => _waehleMitSpeichernDialog,
);

const _xmlDateien = XTypeGroup(
  label: 'XML',
  extensions: ['xml'],
  mimeTypes: ['application/xml', 'text/xml'],
);

Future<String?> _waehleMitSpeichernDialog(String vorgeschlagenerName) async {
  final ziel = await getSaveLocation(
    acceptedTypeGroups: [_xmlDateien],
    suggestedName: vorgeschlagenerName,
    confirmButtonText: 'Exportieren',
    canCreateDirectories: true,
  );
  return ziel?.path;
}
