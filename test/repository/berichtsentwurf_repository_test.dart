import 'package:flutter_test/flutter_test.dart';
import 'package:jldb/jldb.dart';
import 'package:julog/jahresbericht/jahresbericht.dart';
import 'package:julog/jahresbericht/manuelle_angaben.dart';
import 'package:julog/repository/berichtsentwurf/repository.dart';
import 'package:julog/repository/model/berichtsentwurf/berichtsentwurf.dart';

void main() {
  late Jldb db;
  late BerichtsentwurfRepository repo;

  setUp(() async {
    db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
    repo = BerichtsentwurfRepository(jldb: db);
  });
  tearDown(() => db.close());

  final angaben = const ManuelleAngaben.leer()
      .withFrage(1, true)
      .withFrage(8, false)
      .copyWith(
        arbeitWert11: 30,
        arbeitWert20: 120,
        einsatzabteilungM: 2,
        einsatzabteilungW: 1,
        einsatzabteilungD: 0,
      );
  final ueberschreibungen = Ueberschreibungen({
    'Arbeit_Wert_01': 12,
    'Arbeit_Wert_13': 0,
  });

  group('BerichtsentwurfRepository', () {
    test('save without a previous year yields an empty draft', () async {
      final entwurf = await repo.save(2024).unwrap();

      expect(entwurf.year, 2024);
      expect(entwurf.angaben, const ManuelleAngaben.leer());
      expect(entwurf.ueberschreibungen, const Ueberschreibungen.keine());
      expect(entwurf.status, EntwurfStatus.entwurf);
      expect(entwurf.exportedAt, isNull);
    });

    test('there is at most one draft per year', () async {
      await repo.save(2024).unwrap();

      final second = await repo.save(2024);

      expect(second, isA<Failure>());
      expect(await repo.getAll().unwrap(), hasLength(1));
    });

    test(
      'getByYear returns None without a draft and the draft with one',
      () async {
        expect((await repo.getByYear(2024).unwrap()) is None, isTrue);

        final created = await repo.save(2024).unwrap();

        expect((await repo.getByYear(2024).unwrap()).unwrap(), created);
      },
    );

    test(
      'update stores angaben and ueberschreibungen as domain types',
      () async {
        await repo.save(2024).unwrap();

        await repo.update((
          year: 2024,
          angaben: angaben,
          ueberschreibungen: ueberschreibungen,
        )).unwrap();

        // A fresh repository reads straight from the file.
        final fresh = BerichtsentwurfRepository(jldb: db);
        final loaded = (await fresh.getByYear(2024).unwrap()).unwrap();
        expect(loaded.angaben, angaben);
        expect(loaded.ueberschreibungen, ueberschreibungen);
        expect(loaded.status, EntwurfStatus.entwurf);

        // The updating repository serves the new values too.
        final cached = (await repo.getByYear(2024).unwrap()).unwrap();
        expect(cached.angaben, angaben);
        expect(cached.ueberschreibungen, ueberschreibungen);
      },
    );

    test('update fails for a year without draft', () async {
      final result = await repo.update((
        year: 2024,
        angaben: angaben,
        ueberschreibungen: ueberschreibungen,
      ));
      expect(result, isA<Failure>());
    });

    test(
      'markExported sets status and date; again only changes the date',
      () async {
        await repo.save(2024).unwrap();

        await repo.markExported(2024, DateTime(2025, 1, 15, 10)).unwrap();
        var loaded = (await repo.getByYear(2024).unwrap()).unwrap();
        expect(loaded.status, EntwurfStatus.exportiert);
        expect(loaded.exportedAt, DateTime(2025, 1, 15, 10));

        await repo.markExported(2024, DateTime(2025, 2, 3, 8)).unwrap();
        final fresh = BerichtsentwurfRepository(jldb: db);
        loaded = (await fresh.getByYear(2024).unwrap()).unwrap();
        expect(loaded.status, EntwurfStatus.exportiert);
        expect(loaded.exportedAt, DateTime(2025, 2, 3, 8));
      },
    );

    test('markExported without a date uses the current time', () async {
      await repo.save(2024).unwrap();
      final before = DateTime.now();

      await repo.markExported(2024).unwrap();

      final loaded = (await repo.getByYear(2024).unwrap()).unwrap();
      expect(loaded.exportedAt, isNotNull);
      expect(
        loaded.exportedAt!.isBefore(
          before.subtract(const Duration(seconds: 1)),
        ),
        isFalse,
      );
    });

    test('markExported fails for a year without draft', () async {
      expect(await repo.markExported(2024, DateTime(2025)), isA<Failure>());
    });

    test('a new year takes over the manual answers of the previous year, '
        'but not overrides or status', () async {
      await repo.save(2023).unwrap();
      await repo.update((
        year: 2023,
        angaben: angaben,
        ueberschreibungen: ueberschreibungen,
      )).unwrap();
      await repo.markExported(2023, DateTime(2024, 1, 5)).unwrap();

      final created = await repo.save(2024).unwrap();

      expect(created.angaben, angaben);
      expect(created.angaben.frage(1), isTrue);
      expect(created.angaben.arbeitWert11, 30);
      expect(created.angaben.arbeitWert20, 120);
      expect(created.angaben.einsatzabteilungM, 2);
      expect(created.ueberschreibungen, const Ueberschreibungen.keine());
      expect(created.status, EntwurfStatus.entwurf);
      expect(created.exportedAt, isNull);

      // The previous year keeps everything.
      final previous = (await repo.getByYear(2023).unwrap()).unwrap();
      expect(previous.ueberschreibungen, ueberschreibungen);
      expect(previous.status, EntwurfStatus.exportiert);
    });

    test('the draft of year - 1 wins over older and later years', () async {
      for (final (year, a) in [
        (2021, const ManuelleAngaben.leer().withFrage(1, false)),
        (2023, angaben),
        (2025, const ManuelleAngaben.leer().withFrage(1, false)),
      ]) {
        await repo.save(year).unwrap();
        await repo.update((
          year: year,
          angaben: a,
          ueberschreibungen: const Ueberschreibungen.keine(),
        )).unwrap();
      }

      final created = await repo.save(2024).unwrap();

      expect(created.angaben, angaben);
    });

    test('without year - 1 the most recent earlier draft is used', () async {
      await repo.save(2020).unwrap();
      await repo.update((
        year: 2020,
        angaben: angaben,
        ueberschreibungen: const Ueberschreibungen.keine(),
      )).unwrap();

      final created = await repo.save(2024).unwrap();

      expect(created.angaben, angaben);
    });

    test(
      'getAll lists all years with status and date, most recent first',
      () async {
        await repo.save(2022).unwrap();
        await repo.save(2024).unwrap();
        await repo.save(2023).unwrap();
        await repo.markExported(2023, DateTime(2024, 3, 1)).unwrap();

        final all = await repo.getAll().unwrap();

        expect(all.map((e) => e.year), [2024, 2023, 2022]);
        expect(all.map((e) => e.status), [
          EntwurfStatus.entwurf,
          EntwurfStatus.exportiert,
          EntwurfStatus.entwurf,
        ]);
        expect(all[1].exportedAt, DateTime(2024, 3, 1));

        // Same order from a fresh repository (read from the file).
        final fresh = await BerichtsentwurfRepository(
          jldb: db,
        ).getAll().unwrap();
        expect(fresh.map((e) => e.year), [2024, 2023, 2022]);
      },
    );
  });
}
