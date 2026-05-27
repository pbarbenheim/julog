import 'dart:convert';
import 'dart:io';

import 'package:jldb/jldb.dart';
import 'package:jldb/src/database/sqlite_worker.dart';
import 'package:jldb/src/migrations.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

JugendlicherCreateDTO _makeJugDto({
  String name = 'Alice',
  Sex sex = Sex.female,
  UUID? replacesId,
}) => JugendlicherCreateDTO(
  name: name,
  sex: sex,
  birthDate: DateTime(2010),
  memberSince: DateTime(2020),
  replacesId: replacesId,
);

/// Creates a full eintrag that satisfies the signing-query inner-join requirement
/// (at least one betreuer AND one jugendlicher linked).
Future<EintragApiModel> _createSignableEintrag(Jldb db) async {
  final katId = UUID.generate();
  await db
      .createKategorie(KategorieApiModel(id: katId, name: 'Sport'))
      .unwrap();
  final betreuer = await db
      .createBetreuer(
        BetreuerApiModel(id: UUID.generate(), name: 'Bob', sex: Sex.male),
      )
      .unwrap();
  final jugId = await db.createJugendlicher(_makeJugDto()).unwrap();
  return db
      .createEintrag(
        EintragApiModel(
          id: UUID.generate(),
          start: DateTime.fromMillisecondsSinceEpoch(
            DateTime(2024, 6, 1, 10).millisecondsSinceEpoch,
          ),
          end: DateTime.fromMillisecondsSinceEpoch(
            DateTime(2024, 6, 1, 12).millisecondsSinceEpoch,
          ),
          kategorieId: katId,
          thema: 'Sportabend',
          betreuerIds: {betreuer.id},
          anwesendeJugendlicherIds: {jugId},
          entschuldigteJugendlicherIds: const {},
        ),
      )
      .unwrap();
}

// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Betreuer
  // -------------------------------------------------------------------------
  group('Betreuer', () {
    late Jldb db;
    setUp(() async {
      db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
    });
    tearDown(() async => db.close());

    test('createBetreuer returns the model verbatim', () async {
      final betreuer = BetreuerApiModel(
        id: UUID.generate(),
        name: 'Maria',
        sex: Sex.female,
      );
      final created = await db.createBetreuer(betreuer).unwrap();
      expect(created, equals(betreuer));
    });

    test('getBetreuer returns Some for an existing id', () async {
      final betreuer = BetreuerApiModel(
        id: UUID.generate(),
        name: 'John',
        sex: Sex.male,
      );
      await db.createBetreuer(betreuer).unwrap();

      final result = await db.getBetreuer(betreuer.id).unwrap();
      expect(result is Some, isTrue);
      expect(result.unwrap(), equals(betreuer));
    });

    test('getBetreuer returns None for an unknown id', () async {
      final result = await db.getBetreuer(UUID.generate()).unwrap();
      expect(result is None, isTrue);
    });

    test('getAllBetreuer returns an empty list for an empty db', () async {
      expect(await db.getAllBetreuer().unwrap(), isEmpty);
    });

    test('getAllBetreuer returns all created records', () async {
      await db
          .createBetreuer(
            BetreuerApiModel(id: UUID.generate(), name: 'A', sex: Sex.male),
          )
          .unwrap();
      await db
          .createBetreuer(
            BetreuerApiModel(id: UUID.generate(), name: 'B', sex: Sex.female),
          )
          .unwrap();
      expect((await db.getAllBetreuer().unwrap()).length, equals(2));
    });

    test('all Sex variants survive the DB round-trip', () async {
      for (final sex in Sex.values) {
        final betreuer = BetreuerApiModel(
          id: UUID.generate(),
          name: 'X',
          sex: sex,
        );
        final created = await db.createBetreuer(betreuer).unwrap();
        expect(created.sex, equals(sex));
      }
    });
  });

  // -------------------------------------------------------------------------
  // Jugendlicher
  // -------------------------------------------------------------------------
  group('Jugendlicher', () {
    late Jldb db;
    setUp(() async {
      db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
    });
    tearDown(() async => db.close());

    test('createJugendlicher returns a UUID', () async {
      final id = await db.createJugendlicher(_makeJugDto()).unwrap();
      expect(id, isA<UUID>());
    });

    test('getJugendlicher returns Some with correct data', () async {
      final id = await db.createJugendlicher(_makeJugDto()).unwrap();
      final result = await db.getJugendlicher(id).unwrap();

      expect(result is Some, isTrue);
      final jug = result.unwrap();
      expect(jug.id, equals(id));
      expect(jug.name, equals('Alice'));
      expect(jug.sex, equals(Sex.female));
    });

    test('getJugendlicher returns None for an unknown id', () async {
      final result = await db.getJugendlicher(UUID.generate()).unwrap();
      expect(result is None, isTrue);
    });

    test('getAllJugendliche returns all created records', () async {
      await db.createJugendlicher(_makeJugDto(name: 'A')).unwrap();
      await db.createJugendlicher(_makeJugDto(name: 'B')).unwrap();
      expect((await db.getAllJugendliche().unwrap()).length, equals(2));
    });

    test('deleteJugendlicher succeeds for an unused record', () async {
      final id = await db.createJugendlicher(_makeJugDto()).unwrap();
      await db.deleteJugendlicher(id).unwrap();

      final after = await db.getJugendlicher(id).unwrap();
      expect(after is None, isTrue);
    });

    test(
      'deleteJugendlicher fails when the jugendlicher has eintraege',
      () async {
        final katId = UUID.generate();
        await db
            .createKategorie(KategorieApiModel(id: katId, name: 'K'))
            .unwrap();
        final jugId = await db.createJugendlicher(_makeJugDto()).unwrap();
        await db
            .createEintrag(
              EintragApiModel(
                id: UUID.generate(),
                start: DateTime(2024),
                end: DateTime(2024, 1, 1, 2),
                kategorieId: katId,
                thema: 'Test',
                betreuerIds: const {},
                anwesendeJugendlicherIds: {jugId},
                entschuldigteJugendlicherIds: const {},
              ),
            )
            .unwrap();

        final result = await db.deleteJugendlicher(jugId);
        expect(result, isA<Failure>());
      },
    );

    test(
      'createJugendlicher with replacesId links the replacement chain',
      () async {
        final aId = await db
            .createJugendlicher(_makeJugDto(name: 'A'))
            .unwrap();
        final bId = await db
            .createJugendlicher(_makeJugDto(name: 'A', replacesId: aId))
            .unwrap();

        final a = (await db.getJugendlicher(aId).unwrap()).unwrap();
        final b = (await db.getJugendlicher(bId).unwrap()).unwrap();

        expect(a.replacedById, equals(bId));
        expect(b.replacesId, equals(aId));
      },
    );

    test(
      'deleteJugendlicher fails for a record that is itself a replacement',
      () async {
        final aId = await db
            .createJugendlicher(_makeJugDto(name: 'A'))
            .unwrap();
        final bId = await db
            .createJugendlicher(_makeJugDto(name: 'A', replacesId: aId))
            .unwrap();

        final result = await db.deleteJugendlicher(bId);
        expect(result, isA<Failure>());
      },
    );

    test('updateJugendlicher persists non-sensitive field changes', () async {
      final id = await db.createJugendlicher(_makeJugDto()).unwrap();
      final newBirth = DateTime(2012, 3, 15);
      final newMember = DateTime(2022, 1, 1);

      await db
          .updateJugendlicher(
            id,
            sex: Sex.male,
            pass: 'P123',
            birthDate: newBirth,
            memberSince: newMember,
          )
          .unwrap();

      final jug = (await db.getJugendlicher(id).unwrap()).unwrap();
      expect(jug.sex, equals(Sex.male));
      expect(jug.pass, equals('P123'));
      expect(jug.birthDate, equals(newBirth));
      expect(jug.memberSince, equals(newMember));
    });

    test(
      'updateJugendlicher does not affect name or replacement chain',
      () async {
        final id = await db.createJugendlicher(_makeJugDto()).unwrap();

        await db
            .updateJugendlicher(
              id,
              sex: Sex.male,
              pass: null,
              birthDate: DateTime(2011),
              memberSince: DateTime(2021),
            )
            .unwrap();

        final jug = (await db.getJugendlicher(id).unwrap()).unwrap();
        expect(jug.name, equals('Alice'));
        expect(jug.replacedById, isNull);
      },
    );

    test('updateJugendlicher clears pass when null', () async {
      final id = await db
          .createJugendlicher(
            JugendlicherCreateDTO(
              name: 'Bob',
              sex: Sex.male,
              birthDate: DateTime(2010),
              memberSince: DateTime(2020),
              pass: 'OLD',
            ),
          )
          .unwrap();

      await db
          .updateJugendlicher(
            id,
            sex: Sex.male,
            pass: null,
            birthDate: DateTime(2010),
            memberSince: DateTime(2020),
          )
          .unwrap();

      final jug = (await db.getJugendlicher(id).unwrap()).unwrap();
      expect(jug.pass, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Kategorie
  // -------------------------------------------------------------------------
  group('Kategorie', () {
    late Jldb db;
    setUp(() async {
      db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
    });
    tearDown(() async => db.close());

    test('createKategorie returns the model verbatim', () async {
      final kat = KategorieApiModel(id: UUID.generate(), name: 'Sport');
      expect(await db.createKategorie(kat).unwrap(), equals(kat));
    });

    test('getKategorie returns Some for an existing id', () async {
      final kat = KategorieApiModel(id: UUID.generate(), name: 'Musik');
      await db.createKategorie(kat).unwrap();

      final result = await db.getKategorie(kat.id).unwrap();
      expect(result is Some, isTrue);
      expect(result.unwrap(), equals(kat));
    });

    test('getKategorie returns None for an unknown id', () async {
      final result = await db.getKategorie(UUID.generate()).unwrap();
      expect(result is None, isTrue);
    });

    test('getAllKategorien returns an empty list for an empty db', () async {
      expect(await db.getAllKategorien().unwrap(), isEmpty);
    });

    test('getAllKategorien returns all created records', () async {
      await db
          .createKategorie(KategorieApiModel(id: UUID.generate(), name: 'A'))
          .unwrap();
      await db
          .createKategorie(KategorieApiModel(id: UUID.generate(), name: 'B'))
          .unwrap();
      expect((await db.getAllKategorien().unwrap()).length, equals(2));
    });
  });

  // -------------------------------------------------------------------------
  // Eintrag
  // -------------------------------------------------------------------------
  group('Eintrag', () {
    late Jldb db;
    late UUID katId;
    late UUID betreuerId;
    late UUID jugAnwesendId;
    late UUID jugEntschuldigtId;

    setUp(() async {
      db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
      katId = UUID.generate();
      await db
          .createKategorie(KategorieApiModel(id: katId, name: 'Sport'))
          .unwrap();
      final b = await db
          .createBetreuer(
            BetreuerApiModel(id: UUID.generate(), name: 'Bob', sex: Sex.male),
          )
          .unwrap();
      betreuerId = b.id;
      jugAnwesendId = await db
          .createJugendlicher(_makeJugDto(name: 'Alice'))
          .unwrap();
      jugEntschuldigtId = await db
          .createJugendlicher(_makeJugDto(name: 'Ben', sex: Sex.male))
          .unwrap();
    });
    tearDown(() async => db.close());

    EintragApiModel makeEintrag({
      String thema = 'Sportabend',
      String? ort,
      String? raum,
      String? dienstverlauf,
      String? besonderheiten,
    }) => EintragApiModel(
      id: UUID.generate(),
      start: DateTime.fromMillisecondsSinceEpoch(
        DateTime(2024, 6, 1, 10).millisecondsSinceEpoch,
      ),
      end: DateTime.fromMillisecondsSinceEpoch(
        DateTime(2024, 6, 1, 12).millisecondsSinceEpoch,
      ),
      kategorieId: katId,
      thema: thema,
      ort: ort,
      raum: raum,
      dienstverlauf: dienstverlauf,
      besonderheiten: besonderheiten,
      betreuerIds: {betreuerId},
      anwesendeJugendlicherIds: {jugAnwesendId},
      entschuldigteJugendlicherIds: {jugEntschuldigtId},
    );

    test('createEintrag round-trips the full model', () async {
      final eintrag = makeEintrag();
      final created = await db.createEintrag(eintrag).unwrap();
      expect(created, equals(eintrag));
    });

    test('getEintrag returns Some and reconstructs the full model', () async {
      final eintrag = makeEintrag();
      await db.createEintrag(eintrag).unwrap();

      final result = await db.getEintrag(eintrag.id).unwrap();
      expect(result is Some, isTrue);
      expect(result.unwrap(), equals(eintrag));
    });

    test('getEintrag returns None for an unknown id', () async {
      final result = await db.getEintrag(UUID.generate()).unwrap();
      expect(result is None, isTrue);
    });

    test('getAllEintraege returns all created entries', () async {
      await db.createEintrag(makeEintrag(thema: 'A')).unwrap();
      await db.createEintrag(makeEintrag(thema: 'B')).unwrap();
      expect((await db.getAllEintraege().unwrap()).length, equals(2));
    });

    test('attendance sets are stored and separated correctly', () async {
      final eintrag = makeEintrag();
      await db.createEintrag(eintrag).unwrap();
      final fetched = (await db.getEintrag(eintrag.id).unwrap()).unwrap();

      expect(fetched.anwesendeJugendlicherIds, contains(jugAnwesendId));
      expect(fetched.entschuldigteJugendlicherIds, contains(jugEntschuldigtId));
      expect(
        fetched.anwesendeJugendlicherIds,
        isNot(contains(jugEntschuldigtId)),
      );
      expect(
        fetched.entschuldigteJugendlicherIds,
        isNot(contains(jugAnwesendId)),
      );
    });

    test('optional text fields survive the round-trip', () async {
      final eintrag = makeEintrag(
        ort: 'Berlin',
        raum: 'Raum 1',
        dienstverlauf: 'Verlauf',
        besonderheiten: 'Besonderes',
      );
      await db.createEintrag(eintrag).unwrap();
      final fetched = (await db.getEintrag(eintrag.id).unwrap()).unwrap();

      expect(fetched.ort, equals('Berlin'));
      expect(fetched.raum, equals('Raum 1'));
      expect(fetched.dienstverlauf, equals('Verlauf'));
      expect(fetched.besonderheiten, equals('Besonderes'));
    });

    test(
      'eintrag with no betreuer and no jugendliche is stored correctly',
      () async {
        final eintrag = EintragApiModel(
          id: UUID.generate(),
          start: DateTime(2024, 6, 1, 10),
          end: DateTime(2024, 6, 1, 12),
          kategorieId: katId,
          thema: 'Leeres Treffen',
          betreuerIds: const {},
          anwesendeJugendlicherIds: const {},
          entschuldigteJugendlicherIds: const {},
        );
        final created = await db.createEintrag(eintrag).unwrap();
        expect(created.betreuerIds, isEmpty);
        expect(created.anwesendeJugendlicherIds, isEmpty);
        expect(created.entschuldigteJugendlicherIds, isEmpty);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Identity
  // -------------------------------------------------------------------------
  group('Identity', () {
    late Jldb db;
    setUp(() async {
      db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
    });
    tearDown(() async => db.close());

    test('createIdentity returns the model verbatim', () async {
      final identity = IdentityApiModel(
        id: UUID.generate(),
        publicKey: 'pk_abc123',
      );
      expect(await db.createIdentity(identity).unwrap(), equals(identity));
    });

    test('getIdentity returns Some for an existing id', () async {
      final identity = IdentityApiModel(
        id: UUID.generate(),
        publicKey: 'pk_xyz',
      );
      await db.createIdentity(identity).unwrap();

      final result = await db.getIdentity(identity.id).unwrap();
      expect(result is Some, isTrue);
      expect(result.unwrap(), equals(identity));
    });

    test('getIdentity returns None for an unknown id', () async {
      final result = await db.getIdentity(UUID.generate()).unwrap();
      expect(result is None, isTrue);
    });

    test('getAllIdentities returns all created records', () async {
      await db
          .createIdentity(
            IdentityApiModel(id: UUID.generate(), publicKey: 'k1'),
          )
          .unwrap();
      await db
          .createIdentity(
            IdentityApiModel(id: UUID.generate(), publicKey: 'k2'),
          )
          .unwrap();
      expect((await db.getAllIdentities().unwrap()).length, equals(2));
    });
  });

  // -------------------------------------------------------------------------
  // Signature
  // -------------------------------------------------------------------------
  group('Signature', () {
    late Jldb db;
    late UUID eintragId;
    late UUID identityId;

    setUp(() async {
      db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
      // Signature requires a referenced eintrag and identity.
      final eintrag = await _createSignableEintrag(db);
      eintragId = eintrag.id;
      final identity = await db
          .createIdentity(
            IdentityApiModel(id: UUID.generate(), publicKey: 'pk1'),
          )
          .unwrap();
      identityId = identity.id;
    });
    tearDown(() async => db.close());

    test('createSignature returns the model verbatim', () async {
      final ts = DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000);
      final sig = SignatureApiModel(
        eintragId: eintragId,
        identityId: identityId,
        signature: 'sig_data',
        timestamp: ts,
        version: 4,
      );
      expect(await db.createSignature(sig).unwrap(), equals(sig));
    });

    test(
      'getSignaturesByEintragId returns empty list when no signatures exist',
      () async {
        expect(await db.getSignaturesByEintragId(eintragId).unwrap(), isEmpty);
      },
    );

    test('getSignaturesByEintragId returns the created signature', () async {
      final ts = DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000);
      final sig = SignatureApiModel(
        eintragId: eintragId,
        identityId: identityId,
        signature: 'sig_data',
        timestamp: ts,
        version: 5,
      );
      await db.createSignature(sig).unwrap();

      final sigs = await db.getSignaturesByEintragId(eintragId).unwrap();
      expect(sigs.length, equals(1));
      expect(sigs.first, equals(sig));
    });

    test(
      'version and timestamp are preserved at millisecond precision',
      () async {
        final ts = DateTime.fromMillisecondsSinceEpoch(1_700_000_000_123);
        final sig = SignatureApiModel(
          eintragId: eintragId,
          identityId: identityId,
          signature: 'sig',
          timestamp: ts,
          version: 5,
        );
        await db.createSignature(sig).unwrap();
        final fetched =
            (await db.getSignaturesByEintragId(eintragId).unwrap()).first;

        expect(fetched.version, equals(5));
        expect(
          fetched.timestamp.millisecondsSinceEpoch,
          equals(ts.millisecondsSinceEpoch),
        );
      },
    );

    test(
      'two signatures for the same eintrag from different identities are both returned',
      () async {
        final identity2 = await db
            .createIdentity(
              IdentityApiModel(id: UUID.generate(), publicKey: 'pk2'),
            )
            .unwrap();
        final ts = DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000);
        await db
            .createSignature(
              SignatureApiModel(
                eintragId: eintragId,
                identityId: identityId,
                signature: 'sig1',
                timestamp: ts,
                version: 4,
              ),
            )
            .unwrap();
        await db
            .createSignature(
              SignatureApiModel(
                eintragId: eintragId,
                identityId: identity2.id,
                signature: 'sig2',
                timestamp: ts,
                version: 4,
              ),
            )
            .unwrap();

        final sigs = await db.getSignaturesByEintragId(eintragId).unwrap();
        expect(sigs.length, equals(2));
      },
    );
  });

  // -------------------------------------------------------------------------
  // Config
  // -------------------------------------------------------------------------
  group('Config', () {
    late Jldb db;
    setUp(() async {
      db = await Jldb.create(':memory:', domain: 'example.org').unwrap();
    });
    tearDown(() async => db.close());

    test('domain is stored by create()', () async {
      final result = await db.getConfigValue('domain').unwrap();
      expect(result is Some, isTrue);
      expect(result.unwrap(), equals('example.org'));
    });

    test('setConfigValue + getConfigValue round-trip', () async {
      await db.setConfigValue('mykey', 'myvalue').unwrap();
      final result = await db.getConfigValue('mykey').unwrap();
      expect(result is Some, isTrue);
      expect(result.unwrap(), equals('myvalue'));
    });

    test('setConfigValue upserts an existing key', () async {
      await db.setConfigValue('domain', 'v1.org').unwrap();
      await db.setConfigValue('domain', 'v2.org').unwrap();
      final result = await db.getConfigValue('domain').unwrap();
      expect(result.unwrap(), equals('v2.org'));
    });

    // BUG: the implementation accesses result[0][0] without checking for an
    // empty result set, so this currently throws a RangeError instead of
    // returning None.  The test documents correct expected behaviour.
    test('getConfigValue returns None for a non-existent key', () async {
      final result = await db.getConfigValue('nonexistent').unwrap();
      expect(result is None, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Database version / open
  // -------------------------------------------------------------------------
  group('Database', () {
    test('getVersion() returns 3 after create()', () async {
      final db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
      addTearDown(db.close);
      expect(await db.getVersion(), equals(3));
    });

    test(
      'open() succeeds for a file previously created with create()',
      () async {
        final dir = await Directory.systemTemp.createTemp('jldb_test_');
        addTearDown(() => dir.delete(recursive: true));
        final path = '${dir.path}/test.db';

        // Use SqliteWorker + DatabaseMigrations directly to avoid the
        // setConfigValue fire-and-forget race that occurs when closing
        // immediately after Jldb.create().
        final worker = await SqliteWorker.spawn(path, createDatabase: true);
        for (final sql in DatabaseMigrations.getMigrations()) {
          await worker.execute(sql);
        }
        await worker.close();

        final opened = await Jldb.open(path).unwrap();
        addTearDown(opened.close);
        expect(await opened.getVersion(), equals(3));
      },
    );

    test(
      'open() fails for a database with user_version below minimum',
      () async {
        final dir = await Directory.systemTemp.createTemp('jldb_test_');
        addTearDown(() => dir.delete(recursive: true));
        final path = '${dir.path}/old.db';

        final worker = await SqliteWorker.spawn(path, createDatabase: true);
        await worker.execute('PRAGMA user_version = 2;');
        await worker.close();

        final result = await Jldb.open(path);
        expect(result, isA<Failure>());
      },
    );
  });

  // -------------------------------------------------------------------------
  // Signing
  // -------------------------------------------------------------------------
  group('Signing', () {
    late Jldb db;
    late EintragApiModel eintrag;

    setUp(() async {
      db = await Jldb.create(':memory:', domain: 'test.org').unwrap();
      eintrag = await _createSignableEintrag(db);
    });
    tearDown(() async => db.close());

    test('v4 payload contains version field equal to 4', () async {
      final optional = await db
          .getEintragForSigning(eintrag.id, 4, DateTime.now())
          .unwrap();
      expect(optional is Some, isTrue);
      final decoded = jsonDecode(optional.unwrap()) as Map<String, dynamic>;
      expect(decoded['version'], equals(4));
    });

    test('v4 payload does not contain a timestamp field', () async {
      final optional = await db
          .getEintragForSigning(eintrag.id, 4, DateTime.now())
          .unwrap();
      final decoded = jsonDecode(optional.unwrap()) as Map<String, dynamic>;
      expect(decoded.containsKey('timestamp'), isFalse);
    });

    test('v5 payload contains version field equal to 5', () async {
      final optional = await db
          .getEintragForSigning(eintrag.id, 5, DateTime.now())
          .unwrap();
      expect(optional is Some, isTrue);
      final decoded = jsonDecode(optional.unwrap()) as Map<String, dynamic>;
      expect(decoded['version'], equals(5));
    });

    test('v5 payload contains the injected timestamp', () async {
      final ts = DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000);
      final optional = await db
          .getEintragForSigning(eintrag.id, 5, ts)
          .unwrap();
      final decoded = jsonDecode(optional.unwrap()) as Map<String, dynamic>;
      expect(decoded['timestamp'], equals(ts.millisecondsSinceEpoch));
    });

    test('v4 and v5 payloads include eintrag id and thema', () async {
      for (final version in [4, 5]) {
        final optional = await db
            .getEintragForSigning(eintrag.id, version, DateTime.now())
            .unwrap();
        final decoded = jsonDecode(optional.unwrap()) as Map<String, dynamic>;
        expect(decoded['id'], equals(eintrag.id.toString()));
        expect(decoded['thema'], equals(eintrag.thema));
      }
    });

    test('returns None for a non-existent eintrag id', () async {
      final result = await db
          .getEintragForSigning(UUID.generate(), 4, DateTime.now())
          .unwrap();
      expect(result is None, isTrue);
    });

    test('returns None for an eintrag with no betreuer linked', () async {
      final katId = UUID.generate();
      await db
          .createKategorie(KategorieApiModel(id: katId, name: 'K'))
          .unwrap();
      final jugId = await db.createJugendlicher(_makeJugDto()).unwrap();
      final noBetrEintrag = await db
          .createEintrag(
            EintragApiModel(
              id: UUID.generate(),
              start: DateTime(2024),
              end: DateTime(2024, 1, 1, 2),
              kategorieId: katId,
              thema: 'Ohne Betreuer',
              betreuerIds: const {},
              anwesendeJugendlicherIds: {jugId},
              entschuldigteJugendlicherIds: const {},
            ),
          )
          .unwrap();

      final result = await db
          .getEintragForSigning(noBetrEintrag.id, 4, DateTime.now())
          .unwrap();
      expect(result is None, isTrue);
    });

    test(
      'throws UnsupportedError for an unrecognised signing version',
      () async {
        expect(
          () => db.getEintragForSigning(eintrag.id, 99, DateTime.now()),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );
  });
}
