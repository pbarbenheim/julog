import 'package:jldb/src/models/jugendlicher/jugendlicher_api_model.dart';
import 'package:jldb/src/models/sex.dart';
import 'package:jldb/src/models/uuid.dart';
import 'package:test/test.dart';

void main() {
  group('JugendlicherApiModel', () {
    final id1 = UUID.fromString('550e8400-e29b-41d4-a716-446655440001');
    final id2 = UUID.fromString('550e8400-e29b-41d4-a716-446655440002');
    final baseDate = DateTime(2000);

    JugendlicherApiModel make({UUID? id, String name = 'Max'}) =>
        JugendlicherApiModel(
          id: id ?? id1,
          name: name,
          sex: Sex.male,
          birthDate: baseDate,
          memberSince: baseDate,
          eintragIds: const {},
        );

    group('canBeUpdatedFrom()', () {
      test('returns true when id and name both match', () {
        expect(make().canBeUpdatedFrom(make()), isTrue);
      });

      test('returns false when names differ', () {
        expect(
          make(name: 'Max').canBeUpdatedFrom(make(name: 'Anna')),
          isFalse,
        );
      });

      test('returns false when ids differ', () {
        expect(
          make(id: id1).canBeUpdatedFrom(make(id: id2)),
          isFalse,
        );
      });

      test('returns false when both id and name differ', () {
        expect(
          make(id: id1, name: 'Max').canBeUpdatedFrom(make(id: id2, name: 'Anna')),
          isFalse,
        );
      });
    });
  });
}
