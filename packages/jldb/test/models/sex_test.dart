import 'package:jldb/src/models/sex.dart';
import 'package:test/test.dart';

void main() {
  group('Sex', () {
    group('toInt()', () {
      test('male maps to 0', () => expect(Sex.male.toInt(), equals(0)));
      test('female maps to 1', () => expect(Sex.female.toInt(), equals(1)));
      test('diverse maps to 2', () => expect(Sex.diverse.toInt(), equals(2)));
    });

    group('fromInt()', () {
      test('0 maps to male', () => expect(Sex.fromInt(0), equals(Sex.male)));
      test('1 maps to female', () => expect(Sex.fromInt(1), equals(Sex.female)));
      test('2 maps to diverse', () => expect(Sex.fromInt(2), equals(Sex.diverse)));

      test('throws ArgumentError for -1', () {
        expect(() => Sex.fromInt(-1), throwsArgumentError);
      });

      test('throws ArgumentError for 3', () {
        expect(() => Sex.fromInt(3), throwsArgumentError);
      });
    });

    test('round-trip for every value', () {
      for (final sex in Sex.values) {
        expect(Sex.fromInt(sex.toInt()), equals(sex));
      }
    });

    // Guards against accidentally adding a new variant without updating the DB mapping.
    test('enum has exactly 3 variants', () {
      expect(Sex.values.length, equals(3));
    });
  });
}
