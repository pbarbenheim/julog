import 'package:jldb/src/models/origin.dart';
import 'package:test/test.dart';

void main() {
  group('Origin', () {
    group('toInt()', () {
      test('neu maps to 0', () => expect(Origin.neu.toInt(), equals(0)));
      test(
        'andereOrganisation maps to 1',
        () => expect(Origin.andereOrganisation.toInt(), equals(1)),
      );
      test(
        'kinderfeuerwehr maps to 2',
        () => expect(Origin.kinderfeuerwehr.toInt(), equals(2)),
      );
    });

    group('fromInt()', () {
      test('0 maps to neu', () => expect(Origin.fromInt(0), Origin.neu));
      test(
        '1 maps to andereOrganisation',
        () => expect(Origin.fromInt(1), Origin.andereOrganisation),
      );
      test(
        '2 maps to kinderfeuerwehr',
        () => expect(Origin.fromInt(2), Origin.kinderfeuerwehr),
      );
      test('throws ArgumentError for -1', () {
        expect(() => Origin.fromInt(-1), throwsArgumentError);
      });
      test('throws ArgumentError for 3', () {
        expect(() => Origin.fromInt(3), throwsArgumentError);
      });
    });

    test('round-trip for every value', () {
      for (final h in Origin.values) {
        expect(Origin.fromInt(h.toInt()), equals(h));
      }
    });

    test('enum has exactly 3 variants', () {
      expect(Origin.values.length, equals(3));
    });
  });
}
