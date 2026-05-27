import 'package:jldb/src/models/exit_reason.dart';
import 'package:test/test.dart';

void main() {
  group('ExitReason', () {
    group('toInt()', () {
      test('uebernahme maps to 0', () => expect(ExitReason.uebernahme.toInt(), equals(0)));
      test('wohnortwechsel maps to 1', () => expect(ExitReason.wohnortwechsel.toInt(), equals(1)));
      test('noInterest maps to 2', () => expect(ExitReason.noInterest.toInt(), equals(2)));
      test('schule maps to 3', () => expect(ExitReason.schule.toInt(), equals(3)));
      test('ausbildung maps to 4', () => expect(ExitReason.ausbildung.toInt(), equals(4)));
      test('ausschluss maps to 5', () => expect(ExitReason.ausschluss.toInt(), equals(5)));
      test('noUebernahme maps to 6', () => expect(ExitReason.noUebernahme.toInt(), equals(6)));
    });

    group('fromInt()', () {
      test('0 maps to uebernahme', () => expect(ExitReason.fromInt(0), equals(ExitReason.uebernahme)));
      test('1 maps to wohnortwechsel', () => expect(ExitReason.fromInt(1), equals(ExitReason.wohnortwechsel)));
      test('2 maps to noInterest', () => expect(ExitReason.fromInt(2), equals(ExitReason.noInterest)));
      test('3 maps to schule', () => expect(ExitReason.fromInt(3), equals(ExitReason.schule)));
      test('4 maps to ausbildung', () => expect(ExitReason.fromInt(4), equals(ExitReason.ausbildung)));
      test('5 maps to ausschluss', () => expect(ExitReason.fromInt(5), equals(ExitReason.ausschluss)));
      test('6 maps to noUebernahme', () => expect(ExitReason.fromInt(6), equals(ExitReason.noUebernahme)));

      test('throws ArgumentError for -1', () {
        expect(() => ExitReason.fromInt(-1), throwsArgumentError);
      });

      test('throws ArgumentError for 7', () {
        expect(() => ExitReason.fromInt(7), throwsArgumentError);
      });
    });

    test('round-trip for every value', () {
      for (final reason in ExitReason.values) {
        expect(ExitReason.fromInt(reason.toInt()), equals(reason));
      }
    });

    // Guards against accidentally adding a new variant without updating the DB mapping.
    test('enum has exactly 7 variants', () {
      expect(ExitReason.values.length, equals(7));
    });
  });
}
