import 'package:flutter_test/flutter_test.dart';
import 'package:jldb/jldb.dart';
import 'package:julog/repository/kategorie/repository.dart';
import 'package:julog/repository/model/model.dart';

void main() {
  late Jldb db;
  late KategorieRepository repo;

  setUp(() async {
    db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
    repo = KategorieRepository(jldb: db);
  });
  tearDown(() => db.close());

  group('KategorieRepository', () {
    test('save without Berichtsthema yields an unassigned Kategorie', () async {
      final kat = await repo.save((
        name: 'Übung',
        berichtsthema: null,
      )).unwrap();

      expect(kat.name, 'Übung');
      expect(kat.berichtsthema, isNull);
    });

    test('save with Berichtsthema keeps it', () async {
      final kat = await repo.save((
        name: 'Sport',
        berichtsthema: Berichtsthema.sport,
      )).unwrap();

      expect(kat.berichtsthema, Berichtsthema.sport);
    });

    test('Sonstiges and unassigned are distinguishable', () async {
      await repo.save((name: 'A', berichtsthema: null)).unwrap();
      await repo.save((
        name: 'B',
        berichtsthema: Berichtsthema.sonstiges,
      )).unwrap();

      final all = await repo.getAll().unwrap();
      expect(all.firstWhere((k) => k.name == 'A').berichtsthema, isNull);
      expect(
        all.firstWhere((k) => k.name == 'B').berichtsthema,
        Berichtsthema.sonstiges,
      );
    });

    test('every Berichtsthema survives a round trip through the db', () async {
      final fresh = KategorieRepository(jldb: db);
      for (final thema in Berichtsthema.values) {
        await repo.save((name: thema.name, berichtsthema: thema)).unwrap();
      }
      final loaded = await fresh.getAll().unwrap();
      for (final thema in Berichtsthema.values) {
        expect(
          loaded.firstWhere((k) => k.name == thema.name).berichtsthema,
          thema,
        );
      }
    });

    test('edit changes name and Berichtsthema in the file', () async {
      final kat = await repo.save((name: 'Alt', berichtsthema: null)).unwrap();

      await repo.edit((
        id: kat.id,
        name: 'Neu',
        berichtsthema: Berichtsthema.ersteHilfeUndPraevention,
      )).unwrap();

      // A fresh repository reads straight from the file.
      final fresh = KategorieRepository(jldb: db);
      final loaded = (await fresh.getAll().unwrap()).single;
      expect(loaded.id, kat.id);
      expect(loaded.name, 'Neu');
      expect(loaded.berichtsthema, Berichtsthema.ersteHilfeUndPraevention);

      // The edited repository serves the new values too.
      final cached = (await repo.getById(kat.id).unwrap()).unwrap();
      expect(cached.name, 'Neu');
      expect(cached.berichtsthema, Berichtsthema.ersteHilfeUndPraevention);
    });

    test('edit can clear the Berichtsthema', () async {
      final kat = await repo.save((
        name: 'K',
        berichtsthema: Berichtsthema.sport,
      )).unwrap();

      await repo.edit((id: kat.id, name: 'K', berichtsthema: null)).unwrap();

      final loaded = (await repo.getById(kat.id).unwrap()).unwrap();
      expect(loaded.berichtsthema, isNull);
    });
  });
}
