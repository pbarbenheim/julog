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

    group('rename of a Kategorie used by a signed Eintrag', () {
      late Kategorie kat;

      setUp(() async {
        kat = await repo.save((name: 'Alt', berichtsthema: null)).unwrap();
        final betreuer = await db
            .createBetreuer(
              BetreuerApiModel(id: UUID.generate(), name: 'B', sex: Sex.male),
            )
            .unwrap();
        final jugId = await db
            .createJugendlicher(
              JugendlicherCreateDTO(
                name: 'J',
                sex: Sex.male,
                origin: Origin.neu,
                birthDate: DateTime(2010),
                memberSince: DateTime(2020),
              ),
            )
            .unwrap();
        final eintrag = await db
            .createEintrag(
              EintragApiModel(
                id: UUID.generate(),
                start: DateTime(2024, 6, 1, 10),
                end: DateTime(2024, 6, 1, 12),
                kategorieId: UUID.fromString(kat.id),
                thema: 'T',
                betreuerIds: {betreuer.id},
                anwesendeJugendlicherIds: {jugId},
                entschuldigteJugendlicherIds: const {},
                undefinierteJugendlicherIds: const {},
              ),
            )
            .unwrap();
        final identity = await db
            .createIdentity(
              IdentityApiModel(id: UUID.generate(), publicKey: 'pk'),
            )
            .unwrap();
        await db
            .createSignature(
              SignatureApiModel(
                eintragId: eintrag.id,
                identityId: identity.id,
                signature: 'sig',
                timestamp: DateTime.fromMillisecondsSinceEpoch(1),
                version: 5,
              ),
            )
            .unwrap();
      });

      test('is a failure and keeps the name', () async {
        final result = await repo.edit((
          id: kat.id,
          name: 'Neu',
          berichtsthema: Berichtsthema.sport,
        ));

        expect(result, isA<Failure>());
        expect(
          (result as Failure).error,
          isA<KategorieNameGesperrtException>(),
        );
        final loaded = (await repo.getById(kat.id).unwrap()).unwrap();
        expect(loaded.name, 'Alt');
      });

      test('still lets the Berichtsthema change', () async {
        await repo.edit((
          id: kat.id,
          name: 'Alt',
          berichtsthema: Berichtsthema.sport,
        )).unwrap();

        final loaded = (await repo.getById(kat.id).unwrap()).unwrap();
        expect(loaded.berichtsthema, Berichtsthema.sport);
      });

      test('isNameGesperrt is true for it, false for an unused one', () async {
        final other = await repo.save((
          name: 'Frei',
          berichtsthema: null,
        )).unwrap();

        expect(await repo.isNameGesperrt(kat.id).unwrap(), isTrue);
        expect(await repo.isNameGesperrt(other.id).unwrap(), isFalse);
      });
    });
  });
}
