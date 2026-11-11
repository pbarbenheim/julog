import 'dart:io';

import 'package:jldb/jldb.dart';
import 'package:test/test.dart';

void main() {
  group('Berichtsentwurf', () {
    late Jldb db;

    setUp(() async {
      db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
    });
    tearDown(() async => db.close());

    test(
      'createBerichtsentwurf without a previous year starts empty',
      () async {
        final created = await db.createBerichtsentwurf(2024).unwrap();

        expect(created.year, equals(2024));
        expect(created.angaben, isEmpty);
        expect(created.ueberschreibungen, isEmpty);
        expect(created.status, equals(BerichtsentwurfStatus.entwurf));
        expect(created.exportedAt, isNull);

        final loaded = (await db.getBerichtsentwurf(2024).unwrap()).unwrap();
        expect(loaded, equals(created));
      },
    );

    test('getBerichtsentwurf returns None for a year without draft', () async {
      final result = await db.getBerichtsentwurf(2024).unwrap();
      expect(result is None, isTrue);
    });

    test('there is at most one draft per year', () async {
      await db.createBerichtsentwurf(2024).unwrap();
      await db
          .updateBerichtsentwurf(
            2024,
            angaben: {'Frage_01': true},
            ueberschreibungen: const {},
          )
          .unwrap();

      final second = await db.createBerichtsentwurf(2024);

      expect(second, isA<Failure>());
      // The existing draft is untouched.
      final loaded = (await db.getBerichtsentwurf(2024).unwrap()).unwrap();
      expect(loaded.angaben, equals({'Frage_01': true}));
      expect(await db.getAllBerichtsentwuerfe().unwrap(), hasLength(1));
    });

    test(
      'updateBerichtsentwurf changes angaben and ueberschreibungen',
      () async {
        await db.createBerichtsentwurf(2024).unwrap();

        await db
            .updateBerichtsentwurf(
              2024,
              angaben: {
                'Frage_01': true,
                'Frage_02': false,
                'Arbeit_Wert_11': 45,
                'Alter_Anz_EA_bis_27_M': 3,
              },
              ueberschreibungen: {'Arbeit_Wert_01': 12, 'Arbeit_Wert_13': 0},
            )
            .unwrap();

        final loaded = (await db.getBerichtsentwurf(2024).unwrap()).unwrap();
        expect(
          loaded.angaben,
          equals({
            'Frage_01': true,
            'Frage_02': false,
            'Arbeit_Wert_11': 45,
            'Alter_Anz_EA_bis_27_M': 3,
          }),
        );
        expect(
          loaded.ueberschreibungen,
          equals({'Arbeit_Wert_01': 12, 'Arbeit_Wert_13': 0}),
        );
        expect(loaded.status, equals(BerichtsentwurfStatus.entwurf));
      },
    );

    test('updateBerichtsentwurf replaces earlier values and only touches '
        'its own year', () async {
      await db.createBerichtsentwurf(2023).unwrap();
      await db.createBerichtsentwurf(2024).unwrap();
      await db
          .updateBerichtsentwurf(
            2023,
            angaben: {'Frage_01': true},
            ueberschreibungen: {'Arbeit_Wert_01': 1},
          )
          .unwrap();
      await db
          .updateBerichtsentwurf(
            2024,
            angaben: {'Frage_01': false},
            ueberschreibungen: {'Arbeit_Wert_01': 2},
          )
          .unwrap();
      await db
          .updateBerichtsentwurf(
            2024,
            angaben: {'Frage_02': true},
            ueberschreibungen: const {},
          )
          .unwrap();

      final d2023 = (await db.getBerichtsentwurf(2023).unwrap()).unwrap();
      final d2024 = (await db.getBerichtsentwurf(2024).unwrap()).unwrap();
      expect(d2023.angaben, equals({'Frage_01': true}));
      expect(d2023.ueberschreibungen, equals({'Arbeit_Wert_01': 1}));
      expect(d2024.angaben, equals({'Frage_02': true}));
      expect(d2024.ueberschreibungen, isEmpty);
    });

    test('updateBerichtsentwurf fails for a year without draft', () async {
      final result = await db.updateBerichtsentwurf(
        2024,
        angaben: const {},
        ueberschreibungen: const {},
      );
      expect(result, isA<Failure>());
      expect(await db.getAllBerichtsentwuerfe().unwrap(), isEmpty);
    });

    group('exported', () {
      final first = DateTime(2025, 1, 15, 10, 30);
      final second = DateTime(2025, 2, 3, 8, 0);

      test('markBerichtsentwurfExported sets status and date', () async {
        await db.createBerichtsentwurf(2024).unwrap();

        await db.markBerichtsentwurfExported(2024, first).unwrap();

        final loaded = (await db.getBerichtsentwurf(2024).unwrap()).unwrap();
        expect(loaded.status, equals(BerichtsentwurfStatus.exportiert));
        expect(loaded.exportedAt, equals(first));
      });

      test('marking again updates the date and keeps the status', () async {
        await db.createBerichtsentwurf(2024).unwrap();
        await db.markBerichtsentwurfExported(2024, first).unwrap();

        await db.markBerichtsentwurfExported(2024, second).unwrap();

        final loaded = (await db.getBerichtsentwurf(2024).unwrap()).unwrap();
        expect(loaded.status, equals(BerichtsentwurfStatus.exportiert));
        expect(loaded.exportedAt, equals(second));
      });

      test('updating an exported draft keeps status and date', () async {
        await db.createBerichtsentwurf(2024).unwrap();
        await db.markBerichtsentwurfExported(2024, first).unwrap();

        await db
            .updateBerichtsentwurf(
              2024,
              angaben: {'Frage_03': true},
              ueberschreibungen: const {},
            )
            .unwrap();

        final loaded = (await db.getBerichtsentwurf(2024).unwrap()).unwrap();
        expect(loaded.angaben, equals({'Frage_03': true}));
        expect(loaded.status, equals(BerichtsentwurfStatus.exportiert));
        expect(loaded.exportedAt, equals(first));
      });

      test('marking only affects the given year', () async {
        await db.createBerichtsentwurf(2023).unwrap();
        await db.createBerichtsentwurf(2024).unwrap();

        await db.markBerichtsentwurfExported(2024, first).unwrap();

        final other = (await db.getBerichtsentwurf(2023).unwrap()).unwrap();
        expect(other.status, equals(BerichtsentwurfStatus.entwurf));
        expect(other.exportedAt, isNull);
      });

      test(
        'markBerichtsentwurfExported fails for a year without draft',
        () async {
          final result = await db.markBerichtsentwurfExported(2024, first);
          expect(result, isA<Failure>());
          expect(await db.getAllBerichtsentwuerfe().unwrap(), isEmpty);
        },
      );
    });

    group('Vorjahresübernahme', () {
      final angaben2023 = <String, Object>{
        'Frage_01': true,
        'Frage_08': false,
        'Arbeit_Wert_11': 30,
        'Arbeit_Wert_20': 120,
        'Alter_Anz_EA_bis_27_M': 2,
        'Alter_Anz_EA_bis_27_W': 1,
        'Alter_Anz_EA_bis_27_D': 0,
      };

      Future<void> prepare2023({bool exported = true}) async {
        await db.createBerichtsentwurf(2023).unwrap();
        await db
            .updateBerichtsentwurf(
              2023,
              angaben: angaben2023,
              ueberschreibungen: {'Arbeit_Wert_01': 99},
            )
            .unwrap();
        if (exported) {
          await db
              .markBerichtsentwurfExported(2023, DateTime(2024, 1, 5))
              .unwrap();
        }
      }

      test('takes over the angaben of the previous year', () async {
        await prepare2023();

        final created = await db.createBerichtsentwurf(2024).unwrap();

        expect(created.angaben, equals(angaben2023));
      });

      test('does not take over overrides, status or export date', () async {
        await prepare2023();

        final created = await db.createBerichtsentwurf(2024).unwrap();

        expect(created.ueberschreibungen, isEmpty);
        expect(created.status, equals(BerichtsentwurfStatus.entwurf));
        expect(created.exportedAt, isNull);
      });

      test('leaves the previous year untouched', () async {
        await prepare2023();

        await db.createBerichtsentwurf(2024).unwrap();

        final previous = (await db.getBerichtsentwurf(2023).unwrap()).unwrap();
        expect(previous.angaben, equals(angaben2023));
        expect(previous.ueberschreibungen, equals({'Arbeit_Wert_01': 99}));
        expect(previous.status, equals(BerichtsentwurfStatus.exportiert));
      });

      test(
        'later edits of the new draft do not change the previous year',
        () async {
          await prepare2023();
          await db.createBerichtsentwurf(2024).unwrap();

          await db
              .updateBerichtsentwurf(
                2024,
                angaben: {'Frage_01': false},
                ueberschreibungen: const {},
              )
              .unwrap();

          final previous = (await db.getBerichtsentwurf(2023).unwrap())
              .unwrap();
          expect(previous.angaben, equals(angaben2023));
        },
      );

      test('uses the draft of year - 1, not an older one', () async {
        await db.createBerichtsentwurf(2021).unwrap();
        await db
            .updateBerichtsentwurf(
              2021,
              angaben: {'Frage_01': false},
              ueberschreibungen: const {},
            )
            .unwrap();
        await prepare2023(exported: false);
        final created = await db.createBerichtsentwurf(2024).unwrap();
        expect(created.angaben, equals(angaben2023));
      });

      test('uses the draft of year - 1 even if a later year exists', () async {
        await prepare2023(exported: false);
        await db.createBerichtsentwurf(2025).unwrap();
        await db
            .updateBerichtsentwurf(
              2025,
              angaben: {'Frage_01': false},
              ueberschreibungen: const {},
            )
            .unwrap();

        final created = await db.createBerichtsentwurf(2024).unwrap();

        expect(created.angaben, equals(angaben2023));
      });

      test('falls back to the most recent earlier draft if year - 1 is '
          'missing', () async {
        await db.createBerichtsentwurf(2020).unwrap();
        await db
            .updateBerichtsentwurf(
              2020,
              angaben: {'Frage_01': true},
              ueberschreibungen: const {},
            )
            .unwrap();

        final created = await db.createBerichtsentwurf(2024).unwrap();

        expect(created.angaben, equals({'Frage_01': true}));
      });

      test('only later years exist: starts empty', () async {
        await db.createBerichtsentwurf(2025).unwrap();
        await db
            .updateBerichtsentwurf(
              2025,
              angaben: {'Frage_01': true},
              ueberschreibungen: const {},
            )
            .unwrap();

        final created = await db.createBerichtsentwurf(2024).unwrap();

        expect(created.angaben, isEmpty);
      });
    });

    test('getAllBerichtsentwuerfe lists every year with status and date, '
        'most recent first', () async {
      await db.createBerichtsentwurf(2022).unwrap();
      await db.createBerichtsentwurf(2024).unwrap();
      await db.createBerichtsentwurf(2023).unwrap();
      await db.markBerichtsentwurfExported(2023, DateTime(2024, 3, 1)).unwrap();

      final all = await db.getAllBerichtsentwuerfe().unwrap();

      expect(all.map((e) => e.year), equals([2024, 2023, 2022]));
      expect(all.map((e) => e.status), [
        BerichtsentwurfStatus.entwurf,
        BerichtsentwurfStatus.exportiert,
        BerichtsentwurfStatus.entwurf,
      ]);
      expect(all[1].exportedAt, equals(DateTime(2024, 3, 1)));
    });

    test(
      'getAllBerichtsentwuerfe is empty for a file without drafts',
      () async {
        expect(await db.getAllBerichtsentwuerfe().unwrap(), isEmpty);
      },
    );
  });

  group('Berichtsentwurf persistence', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('jldb_test_');
    });
    tearDown(() => dir.delete(recursive: true));

    test('draft survives closing and reopening the file', () async {
      final path = '${dir.path}/entwurf.db';
      final file = await Jldb.create(path, domain: 'test.org').unwrap();
      await file.createBerichtsentwurf(2023).unwrap();
      await file.createBerichtsentwurf(2024).unwrap();
      await file
          .updateBerichtsentwurf(
            2024,
            angaben: {'Frage_01': true, 'Frage_02': false, 'Arbeit_Wert_11': 7},
            ueberschreibungen: {'Arbeit_Wert_03': 4},
          )
          .unwrap();
      await file
          .markBerichtsentwurfExported(2024, DateTime(2025, 1, 15, 10, 30))
          .unwrap();
      await file.close();

      final reopened = await Jldb.open(path).unwrap();
      addTearDown(reopened.close);

      final loaded = (await reopened.getBerichtsentwurf(2024).unwrap())
          .unwrap();
      expect(loaded.year, equals(2024));
      expect(
        loaded.angaben,
        equals({'Frage_01': true, 'Frage_02': false, 'Arbeit_Wert_11': 7}),
      );
      expect(loaded.ueberschreibungen, equals({'Arbeit_Wert_03': 4}));
      expect(loaded.status, equals(BerichtsentwurfStatus.exportiert));
      expect(loaded.exportedAt, equals(DateTime(2025, 1, 15, 10, 30)));
      expect(await reopened.getAllBerichtsentwuerfe().unwrap(), hasLength(2));
    });

    test('a reopened file still allows only one draft per year', () async {
      final path = '${dir.path}/entwurf.db';
      final file = await Jldb.create(path, domain: 'test.org').unwrap();
      await file.createBerichtsentwurf(2024).unwrap();
      await file.close();

      final reopened = await Jldb.open(path).unwrap();
      addTearDown(reopened.close);

      expect(await reopened.createBerichtsentwurf(2024), isA<Failure>());
    });
  });
}
