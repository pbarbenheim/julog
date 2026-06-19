import 'package:jldb/jldb.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

EintragApiModel _makeEintrag({
  required DateTime start,
  Set<UUID>? anwesend,
  Set<UUID>? entschuldigt,
}) => EintragApiModel(
  id: UUID.generate(),
  start: start,
  end: start.add(const Duration(hours: 2)),
  kategorieId: UUID.generate(),
  thema: 'Treffen',
  betreuerIds: const {},
  anwesendeJugendlicherIds: anwesend ?? const {},
  entschuldigteJugendlicherIds: entschuldigt ?? const {},
  undefinierteJugendlicherIds: const {},
);

JugendlicherApiModel _makeJugendlicher({
  UUID? id,
  DateTime? exitDate,
  UUID? replacedById,
}) => JugendlicherApiModel(
  id: id ?? UUID.generate(),
  name: 'Test',
  sex: Sex.male,
  birthDate: DateTime(2000),
  memberSince: DateTime(2020),
  exitDate: exitDate,
  replacedById: replacedById,
  eintragIds: const {},
);

// ---------------------------------------------------------------------------

void main() {
  group('AttendanceRateCalculator', () {
    final sessionDate = DateTime(2024, 6, 1, 10);

    test('returns 1.0 when all aktive members were anwesend', () {
      final jug1 = _makeJugendlicher();
      final jug2 = _makeJugendlicher();
      final eintrag = _makeEintrag(
        start: sessionDate,
        anwesend: {jug1.id, jug2.id},
      );

      final result = AttendanceRateCalculator.calculate(
        [eintrag],
        [jug1, jug2],
      );

      expect(result.length, equals(1));
      expect(result.first.attendanceRate, equals(1.0));
      expect(result.first.date, equals(sessionDate));
    });

    test('entschuldigte members do not count toward numerator', () {
      final jug1 = _makeJugendlicher();
      final jug2 = _makeJugendlicher();
      // Only jug1 is anwesend, jug2 is entschuldigt — numerator is 1, denominator is 2
      final eintrag = _makeEintrag(
        start: sessionDate,
        anwesend: {jug1.id},
        entschuldigt: {jug2.id},
      );

      final result = AttendanceRateCalculator.calculate(
        [eintrag],
        [jug1, jug2],
      );

      expect(result.first.attendanceRate, closeTo(0.5, 0.0001));
    });

    test(
      'Jugendlicher who exited before session date is not in denominator',
      () {
        final activeJug = _makeJugendlicher();
        final exitedJug = _makeJugendlicher(
          exitDate: DateTime(2024, 5, 31), // exited before sessionDate
        );
        // Only activeJug is in denominator; both anwesend → 1/1
        final eintrag = _makeEintrag(
          start: sessionDate,
          anwesend: {activeJug.id},
        );

        final result = AttendanceRateCalculator.calculate(
          [eintrag],
          [activeJug, exitedJug],
        );

        expect(result.first.attendanceRate, equals(1.0));
      },
    );

    test('Jugendlicher who exited on session date is still in denominator', () {
      final jug1 = _makeJugendlicher();
      final jugExitedSameDay = _makeJugendlicher(exitDate: sessionDate);
      // Both aktiv → denominator is 2; only jug1 anwesend → 0.5
      final eintrag = _makeEintrag(start: sessionDate, anwesend: {jug1.id});

      final result = AttendanceRateCalculator.calculate(
        [eintrag],
        [jug1, jugExitedSameDay],
      );

      expect(result.first.attendanceRate, closeTo(0.5, 0.0001));
    });

    test(
      'replaced Jugendlicher (replacedById != null) is excluded from denominator',
      () {
        final activeJug = _makeJugendlicher();
        final replacedJug = _makeJugendlicher(replacedById: UUID.generate());
        // replacedJug is excluded → denominator is 1; activeJug anwesend → 1.0
        final eintrag = _makeEintrag(
          start: sessionDate,
          anwesend: {activeJug.id},
        );

        final result = AttendanceRateCalculator.calculate(
          [eintrag],
          [activeJug, replacedJug],
        );

        expect(result.first.attendanceRate, equals(1.0));
      },
    );

    test('returns 0.0 when no Jugendliche were aktiv on the session date', () {
      final exitedJug = _makeJugendlicher(
        exitDate: DateTime(2024, 1, 1), // exited long before session
      );
      final eintrag = _makeEintrag(start: sessionDate);

      final result = AttendanceRateCalculator.calculate([eintrag], [exitedJug]);

      expect(result.first.attendanceRate, equals(0.0));
    });

    test('returns 0.0 when Jugendliche list is empty', () {
      final eintrag = _makeEintrag(start: sessionDate);

      final result = AttendanceRateCalculator.calculate([eintrag], []);

      expect(result.first.attendanceRate, equals(0.0));
    });

    test('input is trimmed to last 20 Eintraege sorted by start descending', () {
      final jugendliche = [_makeJugendlicher()];

      // Create 25 Einträge spanning different dates
      final eintraege = List.generate(25, (i) {
        return _makeEintrag(
          start: DateTime(2024, 1, i + 1),
          anwesend: {jugendliche.first.id},
        );
      });

      final result = AttendanceRateCalculator.calculate(eintraege, jugendliche);

      expect(result.length, equals(20));
      // The results should be sorted descending by date — first entry is the most recent
      expect(result.first.date, equals(DateTime(2024, 1, 25)));
      expect(result.last.date, equals(DateTime(2024, 1, 6)));
    });

    test('returns empty list when no Eintraege provided', () {
      final result = AttendanceRateCalculator.calculate([], [
        _makeJugendlicher(),
      ]);
      expect(result, isEmpty);
    });
  });
}
