import 'package:jldb/src/models/eintrag/eintrag_api_model.dart';
import 'package:jldb/src/models/uuid.dart';
import 'package:test/test.dart';

void main() {
  group('eintragApiModelFromDbArray', () {
    const eintragId = '550e8400-e29b-41d4-a716-446655440001';
    const kategorieId = '550e8400-e29b-41d4-a716-446655440002';
    const jugId1 = '550e8400-e29b-41d4-a716-446655440003';
    const jugId2 = '550e8400-e29b-41d4-a716-446655440004';
    const betreuerId = '550e8400-e29b-41d4-a716-446655440005';

    // Full column list matching the actual DB query.
    const fullColumns = [
      'id',
      'start',
      'end',
      'kategorie_id',
      'thema',
      'ort',
      'raum',
      'dienstverlauf',
      'besonderheiten',
      'status_jugendlicher_ids',
      'betreuer_ids',
    ];

    final startMs = DateTime(2024, 6, 1, 10).millisecondsSinceEpoch;
    final endMs = DateTime(2024, 6, 1, 12).millisecondsSinceEpoch;

    List<Object?> makeRow({
      String? jugendliche,
      String? betreuer,
      String? ort,
      String? raum,
      String? dienstverlauf,
      String? besonderheiten,
    }) => [
      eintragId,
      startMs,
      endMs,
      kategorieId,
      'Sportabend',
      ort,
      raum,
      dienstverlauf,
      besonderheiten,
      jugendliche,
      betreuer,
    ];

    test('parses minimal row with no jugendliche and no betreuer', () {
      final model = eintragApiModelFromDbArray(makeRow(), fullColumns);

      expect(model.id, equals(UUID.fromString(eintragId)));
      expect(model.kategorieId, equals(UUID.fromString(kategorieId)));
      expect(model.thema, equals('Sportabend'));
      expect(model.start, equals(DateTime.fromMillisecondsSinceEpoch(startMs)));
      expect(model.end, equals(DateTime.fromMillisecondsSinceEpoch(endMs)));
      expect(model.betreuerIds, isEmpty);
      expect(model.anwesendeJugendlicherIds, isEmpty);
      expect(model.entschuldigteJugendlicherIds, isEmpty);
      expect(model.undefinierteJugendlicherIds, isEmpty);
      expect(model.ort, isNull);
      expect(model.raum, isNull);
      expect(model.dienstverlauf, isNull);
      expect(model.besonderheiten, isNull);
    });

    test('round-trips optional text fields', () {
      final model = eintragApiModelFromDbArray(
        makeRow(
          ort: 'Berlin',
          raum: 'Raum 1',
          dienstverlauf: 'Verlauf',
          besonderheiten: 'Besonderes',
        ),
        fullColumns,
      );

      expect(model.ort, equals('Berlin'));
      expect(model.raum, equals('Raum 1'));
      expect(model.dienstverlauf, equals('Verlauf'));
      expect(model.besonderheiten, equals('Besonderes'));
    });

    test('classifies status 1 as anwesend', () {
      final model = eintragApiModelFromDbArray(
        makeRow(jugendliche: '$jugId1:1'),
        fullColumns,
      );

      expect(model.anwesendeJugendlicherIds, contains(UUID.fromString(jugId1)));
      expect(model.entschuldigteJugendlicherIds, isEmpty);
    });

    test('classifies status 2 as entschuldigt', () {
      final model = eintragApiModelFromDbArray(
        makeRow(jugendliche: '$jugId1:2'),
        fullColumns,
      );

      expect(
        model.entschuldigteJugendlicherIds,
        contains(UUID.fromString(jugId1)),
      );
      expect(model.anwesendeJugendlicherIds, isEmpty);
    });

    test('splits mixed attendance correctly across both sets', () {
      final model = eintragApiModelFromDbArray(
        makeRow(jugendliche: '$jugId1:1,$jugId2:2'),
        fullColumns,
      );

      expect(model.anwesendeJugendlicherIds, contains(UUID.fromString(jugId1)));
      expect(
        model.entschuldigteJugendlicherIds,
        contains(UUID.fromString(jugId2)),
      );
      expect(model.anwesendeJugendlicherIds.length, equals(1));
      expect(model.entschuldigteJugendlicherIds.length, equals(1));
    });

    test('parses a single betreuer id', () {
      final model = eintragApiModelFromDbArray(
        makeRow(betreuer: betreuerId),
        fullColumns,
      );

      expect(model.betreuerIds, contains(UUID.fromString(betreuerId)));
    });

    test('parses multiple betreuer ids', () {
      final model = eintragApiModelFromDbArray(
        makeRow(betreuer: '$betreuerId,$jugId1'),
        fullColumns,
      );

      expect(model.betreuerIds.length, equals(2));
      expect(model.betreuerIds, contains(UUID.fromString(betreuerId)));
      expect(model.betreuerIds, contains(UUID.fromString(jugId1)));
    });

    test(
      'throws FormatException for a malformed jugendlicher status entry',
      () {
        expect(
          () => eintragApiModelFromDbArray(
            makeRow(jugendliche: 'no-colon-here'),
            fullColumns,
          ),
          throwsFormatException,
        );
      },
    );

    test('works without optional columns returning null for absent fields', () {
      const minColumns = [
        'id',
        'start',
        'end',
        'kategorie_id',
        'thema',
        'status_jugendlicher_ids',
        'betreuer_ids',
      ];
      final minRow = [
        eintragId,
        startMs,
        endMs,
        kategorieId,
        'Test',
        null,
        null,
      ];
      final model = eintragApiModelFromDbArray(minRow, minColumns);

      expect(model.ort, isNull);
      expect(model.raum, isNull);
      expect(model.dienstverlauf, isNull);
      expect(model.besonderheiten, isNull);
    });

    test('asserts that the id column is present', () {
      final noId = [
        'start',
        'end',
        'kategorie_id',
        'thema',
        'status_jugendlicher_ids',
        'betreuer_ids',
      ];
      expect(
        () => eintragApiModelFromDbArray([], noId),
        throwsA(isA<AssertionError>()),
      );
    });

    test('classifies status 0 as undefiniert', () {
      final model = eintragApiModelFromDbArray(
        makeRow(jugendliche: '$jugId1:0'),
        fullColumns,
      );

      expect(
        model.undefinierteJugendlicherIds,
        contains(UUID.fromString(jugId1)),
      );
      expect(model.anwesendeJugendlicherIds, isEmpty);
      expect(model.entschuldigteJugendlicherIds, isEmpty);
    });

    test('classifies unknown status (99) as undefiniert', () {
      final model = eintragApiModelFromDbArray(
        makeRow(jugendliche: '$jugId1:99'),
        fullColumns,
      );

      expect(
        model.undefinierteJugendlicherIds,
        contains(UUID.fromString(jugId1)),
      );
      expect(model.anwesendeJugendlicherIds, isEmpty);
      expect(model.entschuldigteJugendlicherIds, isEmpty);
    });

    test('splits mixed attendance correctly across all three groups', () {
      const jugId3 = '550e8400-e29b-41d4-a716-446655440006';
      final model = eintragApiModelFromDbArray(
        makeRow(jugendliche: '$jugId1:1,$jugId2:2,$jugId3:0'),
        fullColumns,
      );

      expect(model.anwesendeJugendlicherIds, equals({UUID.fromString(jugId1)}));
      expect(
        model.entschuldigteJugendlicherIds,
        equals({UUID.fromString(jugId2)}),
      );
      expect(
        model.undefinierteJugendlicherIds,
        equals({UUID.fromString(jugId3)}),
      );
    });
  });
}
