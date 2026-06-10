import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jldb/jldb.dart';

import 'package:julog/repository/model/model.dart';
import 'package:julog/repository/repository_base.dart';
import 'package:julog/view_model/dashboard/dashboard_viewmodel.dart';

// ---------------------------------------------------------------------------
// Generic in-memory stub — same pattern as eintrag_assembly_test.dart
// ---------------------------------------------------------------------------

class _Stub<M extends Object, A extends Object, S extends Object>
    extends JulogRepository<M, A, S> {
  final List<M> _items;
  final String Function(M) _idOf;

  _Stub(this._items, this._idOf);

  @override
  AsyncResult<Optional<M>> getById(String id) async => Success(
    Optional.fromNullable(
      _items.where((item) => _idOf(item) == id).firstOrNull,
    ),
  );

  @override
  AsyncResult<List<M>> getAll() async => Success(List.of(_items));

  @override
  AsyncResult<M> createInJldb(S data) => throw UnimplementedError();

  @override
  AsyncResult<List<A>> fetchAllFromJldb() => throw UnimplementedError();

  @override
  FutureOr<M> fromJldbRecord(A record) => throw UnimplementedError();

  @override
  String getId(M item) => _idOf(item);
}

// ---------------------------------------------------------------------------
// UUIDs used as test IDs (UUID.fromString validates format)
// ---------------------------------------------------------------------------

// Valid RFC4122 v4 UUIDs: version digit = 4 (3rd group), variant digit = a (4th group)
const _jugId1 = '11111111-1111-4111-a111-111111111111';
const _jugId2 = '22222222-2222-4222-a222-222222222222';
const _jugId3 = '33333333-3333-4333-a333-333333333333';
const _jugId4 = '44444444-4444-4444-a444-444444444444';
const _eintragId1 = '55555555-5555-4555-a555-555555555555';
const _eintragId2 = '66666666-6666-4666-a666-666666666666';
const _kategorieId1 = '77777777-7777-4777-a777-777777777777';

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

Jugendlicher _jugendlicher({
  required String id,
  DateTime? exitDate,
  Jugendlicher? replacedBy,
  DateTime? birthDate,
}) => Jugendlicher(
  id: id,
  name: 'Jug $id',
  gender: Gender.male,
  birthDate: birthDate ?? DateTime(2005, 6, 15),
  memberSince: DateTime(2020),
  exitDate: exitDate,
  replacedBy: replacedBy,
  eintragIds: const {},
);

Eintrag _eintrag({
  String id = _eintragId1,
  String kategorieId = _kategorieId1,
  required DateTime start,
  Set<String> anwesendeIds = const {},
}) => Eintrag(
  id: id,
  start: start,
  end: start.add(const Duration(hours: 2)),
  kategorieId: kategorieId,
  thema: 'Treffen',
  betreuerIds: const {},
  anwesendeJugendlicherIds: anwesendeIds,
  entschuldigteJugendlicherIds: const {},
);

Kategorie _kategorie(String id) => Kategorie(id: id, name: 'Kategorie $id');

DashboardViewModel _vm({
  List<Jugendlicher> jugendliche = const [],
  List<Eintrag> eintraege = const [],
  List<Kategorie> kategorien = const [],
}) => DashboardViewModel(
  jugendlicheRepo: _Stub(jugendliche, (j) => j.id),
  eintragRepo: _Stub(eintraege, (e) => e.id),
  kategorieRepo: _Stub(kategorien, (k) => k.id),
);

// ---------------------------------------------------------------------------

void main() {
  final today = DateTime(2026, 6, 10);

  group('DashboardViewModel.aktivCount', () {
    test(
      'counts only aktive Jugendliche (not ausgetreten, not replaced)',
      () async {
        final active = _jugendlicher(id: _jugId1);
        final ausgetreten = _jugendlicher(
          id: _jugId2,
          exitDate: DateTime(2026, 1, 1),
        );
        // replacedBy means this jugendlicher was replaced by a newer one
        final replacement = _jugendlicher(id: _jugId3);
        final replaced = _jugendlicher(id: _jugId4, replacedBy: replacement);

        final vm = _vm(
          jugendliche: [active, ausgetreten, replaced, replacement],
        );
        final data = await vm.build(today);

        expect(data.aktivCount, 2);
      },
    );

    test('excludes ausgetretene whose exitDate is before today', () async {
      final yesterday = today.subtract(const Duration(days: 1));
      final ausgetreten = _jugendlicher(id: _jugId1, exitDate: yesterday);
      final vm = _vm(jugendliche: [ausgetreten]);
      final data = await vm.build(today);
      expect(data.aktivCount, 0);
    });

    test(
      'includes Jugendliche whose exitDate is today (not ausgetreten yet)',
      () async {
        final exitToday = _jugendlicher(id: _jugId1, exitDate: today);
        final vm = _vm(jugendliche: [exitToday]);
        final data = await vm.build(today);
        expect(data.aktivCount, 1);
      },
    );
  });

  group('DashboardViewModel.lastEintrag', () {
    test('is null when no Eintraege exist', () async {
      final vm = _vm(jugendliche: [_jugendlicher(id: _jugId1)]);
      final data = await vm.build(today);
      expect(data.lastEintrag, isNull);
    });

    test('picks the most recent Eintrag by start date', () async {
      final older = _eintrag(
        id: _eintragId2,
        start: DateTime(2026, 1, 1),
        kategorieId: _kategorieId1,
      );
      final newer = _eintrag(
        id: _eintragId1,
        start: DateTime(2026, 5, 1),
        kategorieId: _kategorieId1,
      );
      final vm = _vm(
        eintraege: [older, newer],
        kategorien: [_kategorie(_kategorieId1)],
      );
      final data = await vm.build(today);
      expect(data.lastEintrag, isNotNull);
      expect(data.lastEintrag!.thema, 'Treffen');
      expect(data.lastEintrag!.formattedDate, '1.5.2026');
    });

    test('resolves Kategorie name', () async {
      final vm = _vm(
        eintraege: [_eintrag(start: DateTime(2026, 5, 1))],
        kategorien: [_kategorie(_kategorieId1)],
      );
      final data = await vm.build(today);
      expect(data.lastEintrag!.kategorieName, 'Kategorie $_kategorieId1');
    });

    test(
      'attendance display includes anwesende count and aktiv count at date',
      () async {
        final aktiv = _jugendlicher(id: _jugId1);
        final eintrag = _eintrag(
          start: DateTime(2026, 5, 1),
          anwesendeIds: {_jugId1},
        );
        final vm = _vm(
          jugendliche: [aktiv],
          eintraege: [eintrag],
          kategorien: [_kategorie(_kategorieId1)],
        );
        final data = await vm.build(today);
        expect(data.lastEintrag!.anwesenheitDisplay, '1 / 1 anwesend');
      },
    );
  });

  group('DashboardViewModel.recentBirthdays', () {
    test('is empty when no Eintraege exist', () async {
      final vm = _vm(jugendliche: [_jugendlicher(id: _jugId1)]);
      final data = await vm.build(today);
      expect(data.recentBirthdays, isEmpty);
    });

    test('is empty when no birthdays fall in the window', () async {
      // today = June 10; last Eintrag = June 5; birthday = March 1 (not in window)
      final jug = _jugendlicher(id: _jugId1, birthDate: DateTime(2005, 3, 1));
      final vm = _vm(
        jugendliche: [jug],
        eintraege: [_eintrag(start: DateTime(2026, 6, 5))],
        kategorien: [_kategorie(_kategorieId1)],
      );
      final data = await vm.build(today);
      expect(data.recentBirthdays, isEmpty);
    });

    test(
      'includes Jugendliche with birthday in window [lastEintragDate, today]',
      () async {
        // today = June 10; last Eintrag = June 1; birthday = June 5 (in window)
        final jug = _jugendlicher(id: _jugId1, birthDate: DateTime(2005, 6, 5));
        final vm = _vm(
          jugendliche: [jug],
          eintraege: [_eintrag(start: DateTime(2026, 6, 1))],
          kategorien: [_kategorie(_kategorieId1)],
        );
        final data = await vm.build(today);
        expect(data.recentBirthdays, hasLength(1));
        expect(data.recentBirthdays.single.name, 'Jug $_jugId1');
      },
    );

    test(
      '21-day cap: does not include birthdays beyond 21 days back',
      () async {
        // today = June 10; last Eintrag = April 1 (70 days ago)
        // window is capped at May 20 (21 days back)
        // birthday = May 15 is outside the capped window
        final jug = _jugendlicher(
          id: _jugId1,
          birthDate: DateTime(2005, 5, 15),
        );
        final vm = _vm(
          jugendliche: [jug],
          eintraege: [_eintrag(start: DateTime(2026, 4, 1))],
          kategorien: [_kategorie(_kategorieId1)],
        );
        final data = await vm.build(today);
        expect(data.recentBirthdays, isEmpty);
      },
    );

    test('21-day cap: includes birthday within capped window', () async {
      // today = June 10; last Eintrag = April 1 (70 days ago)
      // window is capped at May 20; birthday = May 25 (in window)
      final jug = _jugendlicher(id: _jugId1, birthDate: DateTime(2005, 5, 25));
      final vm = _vm(
        jugendliche: [jug],
        eintraege: [_eintrag(start: DateTime(2026, 4, 1))],
        kategorien: [_kategorie(_kategorieId1)],
      );
      final data = await vm.build(today);
      expect(data.recentBirthdays, hasLength(1));
    });

    test('excludes ausgetretene Jugendliche from birthday list', () async {
      final ausgetreten = _jugendlicher(
        id: _jugId1,
        exitDate: DateTime(2026, 1, 1),
        birthDate: DateTime(2005, 6, 5),
      );
      final vm = _vm(
        jugendliche: [ausgetreten],
        eintraege: [_eintrag(start: DateTime(2026, 6, 1))],
        kategorien: [_kategorie(_kategorieId1)],
      );
      final data = await vm.build(today);
      expect(data.recentBirthdays, isEmpty);
    });
  });

  group('DashboardViewModel.attendanceChart', () {
    test('returns empty chart when no Eintraege exist', () async {
      final vm = _vm();
      final data = await vm.build(today);
      expect(data.attendanceChart, isEmpty);
    });

    test('delegates to AttendanceRateCalculator (correct rate)', () async {
      final jug = _jugendlicher(id: _jugId1);
      final eintrag = _eintrag(
        start: DateTime(2026, 5, 1),
        anwesendeIds: {_jugId1},
      );
      final vm = _vm(
        jugendliche: [jug],
        eintraege: [eintrag],
        kategorien: [_kategorie(_kategorieId1)],
      );
      final data = await vm.build(today);
      expect(data.attendanceChart, hasLength(1));
      expect(data.attendanceChart.single.attendanceRate, 1.0);
    });
  });
}
