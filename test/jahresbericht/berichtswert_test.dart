import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'builders.dart';

/// Schlüssel der Beispiel-XML. Die Fixture schreibt Umlaute als
/// Zeichenreferenz (`&#xDC;`), diese werden hier aufgelöst.
Set<String> _fixtureKeys() {
  final xml = File(
    'test/fixtures/jahresbericht_beispiel.xml',
  ).readAsStringSync();
  return RegExp(r'key="([^"]+)"')
      .allMatches(xml)
      .map(
        (m) => m
            .group(1)!
            .replaceAllMapped(
              RegExp(r'&#x([0-9A-Fa-f]+);'),
              (r) => String.fromCharCode(int.parse(r.group(1)!, radix: 16)),
            ),
      )
      .toSet();
}

void main() {
  group('Berichtswert', () {
    test('alle Schlüssel sind Felder des Import-Formats', () {
      final keys = bericht(2025).felder.keys.toSet();
      expect(keys.difference(_fixtureKeys()), isEmpty);
    });

    test('enthält genau die Zählwert-Felder des Import-Formats', () {
      final zaehlKeys = _fixtureKeys().where(
        (k) =>
            k.startsWith('Betreuer_Anz_') ||
            k.startsWith('Mitglieder_Anz_') ||
            k.startsWith('Zugang_Anz_') ||
            k.startsWith('Abgang_Anz_') ||
            k.startsWith('Grund_SO_') ||
            (k.startsWith('Alter_Anz_') && !k.startsWith('Alter_Anz_EA_')),
      );
      expect(
        bericht(2025).felder.keys.where((k) => !k.startsWith('Arbeit_Wert_')),
        unorderedEquals(zaehlKeys),
      );
    });

    test('enthält genau die berechneten Arbeitswert-Felder', () {
      final arbeitKeys = _fixtureKeys().where(
        (k) =>
            k.startsWith('Arbeit_Wert_') &&
            k != 'Arbeit_Wert_11' &&
            k != 'Arbeit_Wert_20',
      );
      expect(
        bericht(2025).felder.keys.where((k) => k.startsWith('Arbeit_Wert_')),
        unorderedEquals(arbeitKeys),
      );
    });

    test('ist unveränderlich', () {
      final b = bericht(2025);
      expect(() => b.felder['Mitglieder_Anz_M'] = 5, throwsUnsupportedError);
    });

    test('unbekannte Felder werfen einen Fehler', () {
      expect(() => bericht(2025)['Gibt_Es_Nicht'], throwsArgumentError);
    });

    test('gleiche Eingaben ergeben gleiche Berichtswerte', () {
      expect(bericht(2025), bericht(2025));
      expect(bericht(2025).hashCode, bericht(2025).hashCode);
    });
  });
}
