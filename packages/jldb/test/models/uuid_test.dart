import 'package:jldb/src/models/uuid.dart';
import 'package:test/test.dart';

void main() {
  group('UUID', () {
    group('generate()', () {
      test('produces a valid v4 UUID string', () {
        final uuid = UUID.generate();
        final v4Pattern = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        );
        expect(uuid.toString(), matches(v4Pattern));
      });

      test('produces unique values across 100 calls', () {
        final uuids = {for (var i = 0; i < 100; i++) UUID.generate()};
        expect(uuids.length, equals(100));
      });
    });

    group('fromString()', () {
      test('accepts a valid lowercase UUID', () {
        const raw = '550e8400-e29b-41d4-a716-446655440000';
        expect(UUID.fromString(raw).toString(), equals(raw));
      });

      test('rejects an empty string', () {
        expect(() => UUID.fromString(''), throwsA(anything));
      });

      test('rejects a non-UUID string', () {
        expect(() => UUID.fromString('not-a-uuid'), throwsA(anything));
      });

      test('rejects a truncated UUID', () {
        expect(
          () => UUID.fromString('550e8400-e29b-41d4'),
          throwsA(anything),
        );
      });

      test('rejects a UUID with invalid characters', () {
        expect(
          () => UUID.fromString('gggggggg-gggg-gggg-gggg-gggggggggggg'),
          throwsA(anything),
        );
      });
    });

    group('equality', () {
      test('equal instances for the same string value', () {
        const raw = '550e8400-e29b-41d4-a716-446655440000';
        expect(UUID.fromString(raw), equals(UUID.fromString(raw)));
      });

      test('hashCode is consistent for equal UUIDs', () {
        const raw = '550e8400-e29b-41d4-a716-446655440000';
        expect(
          UUID.fromString(raw).hashCode,
          equals(UUID.fromString(raw).hashCode),
        );
      });

      test('generated UUIDs are not equal to each other', () {
        expect(UUID.generate(), isNot(equals(UUID.generate())));
      });
    });

    group('UUIDExtension', () {
      test('toUUID() converts a valid string', () {
        const raw = '550e8400-e29b-41d4-a716-446655440000';
        expect(raw.toUUID(), equals(UUID.fromString(raw)));
      });

      test('toUUID() throws on an invalid string', () {
        expect(() => 'bad'.toUUID(), throwsA(anything));
      });
    });
  });
}
