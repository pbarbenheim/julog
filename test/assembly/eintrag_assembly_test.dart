import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlcrypto/jlcrypto.dart' as crypto;
import 'package:jldb/jldb.dart';

import 'package:julog/assembly/eintrag_assembly.dart';
import 'package:julog/repository/eintrag/eintrag_repo.dart';
import 'package:julog/repository/identity/repository.dart';
import 'package:julog/repository/jugendliche/repository.dart';
import 'package:julog/repository/kategorie/repository.dart';
import 'package:julog/repository/model/model.dart';
import 'package:julog/repository/repository_base.dart';
import 'package:julog/repository/signature/signature_repository.dart';

// Generic in-memory stub. Overrides getAll/getById with hardcoded data.
// The abstract template methods (createInJldb, fetchAllFromJldb, fromJldbRecord)
// throw UnimplementedError — EintragAssembly never calls them.
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
// Test fixtures
// ---------------------------------------------------------------------------

late crypto.PublicKey _testPublicKey;

Identity _identity(String id) =>
    ClosedIdentity(id: id, publicKey: _testPublicKey, isLocal: false);

Signature _sig(String eintragId, String identityId) => Signature(
  eintragId: eintragId,
  identityId: identityId,
  signature: crypto.Signature(Uint8List.fromList([1, 2, 3])),
  timestamp: DateTime(2024),
  version: 4,
  isValid: true,
);

Eintrag _eintrag({
  String id = 'e1',
  String kategorieId = 'k1',
  Set<String> betreuerIds = const {},
  Set<String> anwesendeIds = const {},
  Set<String> entschuldigteIds = const {},
  Set<String> undefinierteIds = const {},
}) => Eintrag(
  id: id,
  start: DateTime(2024, 3, 1, 10),
  end: DateTime(2024, 3, 1, 12),
  kategorieId: kategorieId,
  thema: 'Erste Hilfe',
  betreuerIds: betreuerIds,
  anwesendeJugendlicherIds: anwesendeIds,
  entschuldigteJugendlicherIds: entschuldigteIds,
  undefinierteJugendlicherIds: undefinierteIds,
  isSigned: false,
);

Kategorie _kategorie(String id) => Kategorie(id: id, name: 'Test Kategorie');

Betreuer _betreuer(String id) =>
    Betreuer(id: id, name: 'Betreuer $id', gender: Gender.male);

Jugendlicher _jugendlicher(String id) => Jugendlicher(
  id: id,
  name: 'Jugendlicher $id',
  gender: Gender.male,
  birthDate: DateTime(2005),
  memberSince: DateTime(2020),
  eintragIds: {},
);

// ---------------------------------------------------------------------------
// Assembly factory — each list becomes a _Stub for its repo
// ---------------------------------------------------------------------------

EintragAssembly _assembly({
  List<Eintrag> eintraege = const [],
  List<Kategorie> kategorien = const [],
  List<Jugendlicher> jugendliche = const [],
  List<Betreuer> betreuer = const [],
  List<Identity> identities = const [],
}) => EintragAssembly(
  eintragRepo: _Stub<Eintrag, EintragApiModel, EintragCreateData>(
    eintraege,
    (e) => e.id,
  ),
  kategorieRepo: _Stub<Kategorie, KategorieApiModel, KategorieCreate>(
    kategorien,
    (k) => k.id,
  ),
  jugendlicheRepo:
      _Stub<Jugendlicher, JugendlicherApiModel, JugendlicheCreateData>(
        jugendliche,
        (j) => j.id,
      ),
  betreuerRepo:
      _Stub<Betreuer, BetreuerApiModel, ({String name, Gender gender})>(
        betreuer,
        (b) => b.id,
      ),
  identityRepo: _Stub<Identity, IdentityApiModel, IdentityCreateData>(
    identities,
    (i) => i.id,
  ),
);

_Stub<Signature, SignatureApiModel, SignatureCreateData> _sigRepo(
  List<Signature> sigs,
) => _Stub(sigs, (s) => s.id);

// ---------------------------------------------------------------------------

void main() {
  setUpAll(() async {
    final pair = await crypto.KeyPair.generateAsync(
      identity: crypto.KeyOwner(
        'Test Name',
        'Gruppenführer',
        'test@example.com',
      ),
      password: 'test-password',
      keySize: 1024,
    );
    _testPublicKey = pair.publicKey;
  });

  group('EintragAssembly.assemble', () {
    test('happy path — all fields assembled correctly', () async {
      final eintrag = _eintrag(
        betreuerIds: {'b1'},
        anwesendeIds: {'j1'},
        entschuldigteIds: {'j2'},
      );
      final identity = _identity('i1');

      final assembly = _assembly(
        eintraege: [eintrag],
        kategorien: [_kategorie('k1')],
        betreuer: [_betreuer('b1')],
        jugendliche: [_jugendlicher('j1'), _jugendlicher('j2')],
        identities: [identity],
      );

      final result = await assembly.assemble(
        'e1',
        _sigRepo([_sig('e1', 'i1')]),
      );

      expect(result, isA<Success<SelectedEintrag>>());
      final s = result.unwrap();
      expect(s.id, 'e1');
      expect(s.thema, 'Erste Hilfe');
      expect(s.kategorie.name, 'Test Kategorie');
      expect(s.betreuer.single.id, 'b1');
      expect(s.anwesendeJugendliche.single.id, 'j1');
      expect(s.entschuldigteJugendliche.single.id, 'j2');
      expect(s.signatures.single.identity.id, 'i1');
      expect(s.signatures.single.isValid, isTrue);
      expect(s.possibleSigners.single.id, 'i1');
    });

    test('empty attendance and signatures — produces empty lists', () async {
      final assembly = _assembly(
        eintraege: [_eintrag()],
        kategorien: [_kategorie('k1')],
      );

      final result = await assembly.assemble('e1', _sigRepo([]));

      expect(result, isA<Success<SelectedEintrag>>());
      final s = result.unwrap();
      expect(s.betreuer, isEmpty);
      expect(s.anwesendeJugendliche, isEmpty);
      expect(s.entschuldigteJugendliche, isEmpty);
      expect(s.signatures, isEmpty);
      expect(s.possibleSigners, isEmpty);
    });

    test('multiple betreuer and jugendliche — all IDs resolved', () async {
      final eintrag = _eintrag(
        betreuerIds: {'b1', 'b2', 'b3'},
        anwesendeIds: {'j1', 'j2'},
        entschuldigteIds: {'j3'},
      );

      final assembly = _assembly(
        eintraege: [eintrag],
        kategorien: [_kategorie('k1')],
        betreuer: [_betreuer('b1'), _betreuer('b2'), _betreuer('b3')],
        jugendliche: [
          _jugendlicher('j1'),
          _jugendlicher('j2'),
          _jugendlicher('j3'),
        ],
      );

      final result = await assembly.assemble('e1', _sigRepo([]));

      final s = result.unwrap();
      expect(s.betreuer.map((b) => b.id).toSet(), {'b1', 'b2', 'b3'});
      expect(s.anwesendeJugendliche.map((j) => j.id).toSet(), {'j1', 'j2'});
      expect(s.entschuldigteJugendliche.single.id, 'j3');
    });

    test(
      'signature identity enrichment — identity joined, isValid propagated',
      () async {
        final id1 = _identity('i1');
        final id2 = _identity('i2');
        final sig1 = _sig('e1', 'i1');
        final sig2 = Signature(
          eintragId: 'e1',
          identityId: 'i2',
          signature: crypto.Signature(Uint8List.fromList([9, 8, 7])),
          timestamp: DateTime(2024),
          version: 4,
          isValid: false,
        );

        final assembly = _assembly(
          eintraege: [_eintrag()],
          kategorien: [_kategorie('k1')],
          identities: [id1, id2],
        );

        final result = await assembly.assemble('e1', _sigRepo([sig1, sig2]));

        final s = result.unwrap();
        expect(s.signatures, hasLength(2));
        final byIdentityId = {
          for (final sig in s.signatures) sig.identity.id: sig,
        };
        expect(byIdentityId['i1']!.isValid, isTrue);
        expect(byIdentityId['i2']!.isValid, isFalse);
        expect(s.possibleSigners.map((i) => i.id).toSet(), {'i1', 'i2'});
      },
    );

    test('eintrag not found — returns Failure', () async {
      final assembly = _assembly(eintraege: [], kategorien: [_kategorie('k1')]);

      final result = await assembly.assemble('e-missing', _sigRepo([]));

      expect(result, isA<Failure<SelectedEintrag>>());
    });

    test('kategorie not found — returns Failure', () async {
      final assembly = _assembly(
        eintraege: [_eintrag(kategorieId: 'k-missing')],
        kategorien: [],
      );

      final result = await assembly.assemble('e1', _sigRepo([]));

      expect(result, isA<Failure<SelectedEintrag>>());
    });

    test('undefinierteJugendliche resolved correctly', () async {
      final eintrag = _eintrag(undefinierteIds: {'j1', 'j2'});

      final assembly = _assembly(
        eintraege: [eintrag],
        kategorien: [_kategorie('k1')],
        jugendliche: [_jugendlicher('j1'), _jugendlicher('j2')],
      );

      final result = await assembly.assemble('e1', _sigRepo([]));

      expect(result, isA<Success<SelectedEintrag>>());
      final s = result.unwrap();
      expect(s.undefinierteJugendliche.map((j) => j.id).toSet(), {'j1', 'j2'});
    });

    test(
      'all three attendance groups simultaneously — each ID in correct list',
      () async {
        final eintrag = _eintrag(
          anwesendeIds: {'j1'},
          entschuldigteIds: {'j2'},
          undefinierteIds: {'j3'},
        );

        final assembly = _assembly(
          eintraege: [eintrag],
          kategorien: [_kategorie('k1')],
          jugendliche: [
            _jugendlicher('j1'),
            _jugendlicher('j2'),
            _jugendlicher('j3'),
          ],
        );

        final result = await assembly.assemble('e1', _sigRepo([]));

        final s = result.unwrap();
        expect(s.anwesendeJugendliche.single.id, 'j1');
        expect(s.entschuldigteJugendliche.single.id, 'j2');
        expect(s.undefinierteJugendliche.single.id, 'j3');
      },
    );
  });
}
