import 'package:flutter_test/flutter_test.dart';
import 'package:julog/jahresbericht/manuelle_angaben.dart';

void main() {
  group('ManuelleAngaben', () {
    test('neue Angaben sind vollständig unbeantwortet', () {
      const a = ManuelleAngaben.leer();
      for (var n = 1; n <= 16; n++) {
        expect(a.frage(n), isNull, reason: 'Frage $n');
      }
      expect(a.arbeitWert11, isNull);
      expect(a.arbeitWert20, isNull);
      expect(a.einsatzabteilungM, isNull);
      expect(a.einsatzabteilungW, isNull);
      expect(a.einsatzabteilungD, isNull);
      expect(a.toMap(), isEmpty);
    });

    test('copyWith setzt einzelne Werte und lässt die übrigen unberührt', () {
      final a = const ManuelleAngaben.leer()
          .copyWith(arbeitWert11: 60)
          .copyWith(einsatzabteilungW: 10)
          .withFrage(4, false);
      expect(a.arbeitWert11, 60);
      expect(a.einsatzabteilungW, 10);
      expect(a.frage(4), false);
      expect(a.frage(5), isNull);
      expect(a.arbeitWert20, isNull);
    });

    test('copyWith kann einen Wert wieder auf unbeantwortet setzen', () {
      final a = ManuelleAngaben(
        arbeitWert20: 230,
        einsatzabteilungM: 15,
      ).copyWith(arbeitWert20: null, einsatzabteilungM: null);
      expect(a.arbeitWert20, isNull);
      expect(a.einsatzabteilungM, isNull);
    });

    test('withFrage kann eine Antwort zurücknehmen', () {
      final a = const ManuelleAngaben.leer()
          .withFrage(3, true)
          .withFrage(3, null);
      expect(a.frage(3), isNull);
      expect(a, const ManuelleAngaben.leer());
    });

    test('Fragenummern außerhalb 1..16 werden abgelehnt', () {
      expect(() => const ManuelleAngaben.leer().frage(0), throwsRangeError);
      expect(() => const ManuelleAngaben.leer().frage(17), throwsRangeError);
      expect(
        () => const ManuelleAngaben.leer().withFrage(17, true),
        throwsRangeError,
      );
      expect(() => ManuelleAngaben(fragen: {0: true}), throwsRangeError);
    });

    test('negative Zahlen werden abgelehnt', () {
      expect(() => ManuelleAngaben(arbeitWert11: -1), throwsArgumentError);
      expect(() => ManuelleAngaben(arbeitWert20: -1), throwsArgumentError);
      expect(() => ManuelleAngaben(einsatzabteilungD: -1), throwsArgumentError);
    });

    test('Gleichheit und hashCode hängen nur von den Werten ab', () {
      final a = const ManuelleAngaben.leer()
          .withFrage(1, true)
          .withFrage(2, false);
      final b = const ManuelleAngaben.leer()
          .withFrage(2, false)
          .withFrage(1, true);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(a.withFrage(2, true)));
      expect(a, isNot(a.copyWith(arbeitWert11: 1)));
    });

    test('ist unveränderlich', () {
      final a = const ManuelleAngaben.leer().withFrage(1, true);
      a.withFrage(1, false);
      expect(a.frage(1), true);
      expect(() => a.fragen[2] = true, throwsUnsupportedError);
    });

    test('toMap verwendet die XML-Feldnamen und lässt Offenes weg', () {
      final a = ManuelleAngaben(
        arbeitWert11: 60,
        einsatzabteilungM: 15,
        einsatzabteilungD: 0,
      ).withFrage(1, true).withFrage(16, false);
      expect(a.toMap(), {
        'Frage_01': true,
        'Frage_16': false,
        'Arbeit_Wert_11': 60,
        'Alter_Anz_EA_bis_27_M': 15,
        'Alter_Anz_EA_bis_27_D': 0,
      });
    });

    test('fromMap(toMap) liefert gleiche Angaben', () {
      final a = ManuelleAngaben(
        arbeitWert11: 60,
        arbeitWert20: 230,
        einsatzabteilungM: 15,
        einsatzabteilungW: 10,
        einsatzabteilungD: 0,
      ).withFrage(2, true).withFrage(9, false);
      expect(ManuelleAngaben.fromMap(a.toMap()), a);
      expect(ManuelleAngaben.fromMap(const {}), const ManuelleAngaben.leer());
    });

    test('fromMap lehnt unbekannte Schlüssel und falsche Typen ab', () {
      expect(
        () => ManuelleAngaben.fromMap({'Frage_17': true}),
        throwsArgumentError,
      );
      expect(() => ManuelleAngaben.fromMap({'Foo': 1}), throwsArgumentError);
      expect(
        () => ManuelleAngaben.fromMap({'Frage_01': 1}),
        throwsArgumentError,
      );
      expect(
        () => ManuelleAngaben.fromMap({'Arbeit_Wert_11': true}),
        throwsArgumentError,
      );
    });
  });
}
