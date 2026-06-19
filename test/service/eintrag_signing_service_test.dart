import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlcrypto/jlcrypto.dart' as crypto;
import 'package:jldb/jldb.dart';

import 'package:julog/repository/identity/exception.dart';
import 'package:julog/repository/model/model.dart';
import 'package:julog/repository/repository_base.dart';
import 'package:julog/repository/signature/signature_repository.dart';
import 'package:julog/service/eintrag_signing_service.dart';

// ---------------------------------------------------------------------------
// Generic stub (same pattern as test/assembly/eintrag_assembly_test.dart)
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

// Signature repo stub that captures save() calls.
class _SavingSignatureStub
    extends _Stub<Signature, SignatureApiModel, SignatureCreateData> {
  final List<SignatureCreateData> saves = [];
  final String eintragId;

  _SavingSignatureStub(this.eintragId) : super([], (s) => s.id);

  @override
  AsyncResult<Signature> createInJldb(SignatureCreateData data) async {
    saves.add(data);
    return Success(
      Signature(
        eintragId: eintragId,
        identityId: data.identityId,
        signature: data.signature,
        timestamp: data.timestamp,
        version: data.version,
        isValid: false,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interface stubs
// ---------------------------------------------------------------------------

class _IdentityOpenerStub implements IdentityOpener {
  final OpenIdentity? _result;
  _IdentityOpenerStub(this._result);

  @override
  AsyncResultOptional<OpenIdentity> openIdentity(
    String id,
    String password,
  ) async => Success(Optional.fromNullable(_result));
}

class _FailingIdentityOpenerStub implements IdentityOpener {
  final Exception _exception;
  _FailingIdentityOpenerStub(this._exception);

  @override
  AsyncResultOptional<OpenIdentity> openIdentity(
    String id,
    String password,
  ) async => Failure(_exception);
}

class _SigningDataStub implements EintragSigningDataSource {
  final String? _data;
  _SigningDataStub(this._data);

  @override
  AsyncResult<Optional<String>> getEintragSigningData(
    String eintragId,
    int version,
    DateTime timestamp,
  ) async => Success(Optional.fromNullable(_data));
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

late crypto.KeyPair _testKeyPair;

// ---------------------------------------------------------------------------

void main() {
  setUpAll(() async {
    _testKeyPair = await crypto.KeyPair.generateAsync(
      identity: crypto.KeyOwner(
        'Test Name',
        'Gruppenführer',
        'test@example.com',
      ),
      password: 'test-password',
      keySize: 1024,
    );
  });

  group('EintragSigningService.sign', () {
    test('happy path — returns VoidSuccess', () async {
      final openIdentity = OpenIdentity(
        id: 'i1',
        privateKey: _testKeyPair.privateKey,
      );

      final service = EintragSigningService(
        identityOpener: _IdentityOpenerStub(openIdentity),
        signingDataSource: _SigningDataStub('signing data string'),
      );
      final sigRepo = _SavingSignatureStub('e1');

      final result = await service.sign(
        eintragId: 'e1',
        identityId: 'i1',
        password: 'test-password',
        signatureRepo: sigRepo,
      );

      expect(result, isA<VoidSuccess>());
      expect(sigRepo.saves, hasLength(1));
      expect(sigRepo.saves.single.identityId, 'i1');
      expect(sigRepo.saves.single.version, 5);
    });

    test('identity not found — returns Failure', () async {
      final service = EintragSigningService(
        identityOpener: _IdentityOpenerStub(null),
        signingDataSource: _SigningDataStub('signing data string'),
      );
      final sigRepo = _SavingSignatureStub('e1');

      final result = await service.sign(
        eintragId: 'e1',
        identityId: 'i1',
        password: 'wrong-password',
        signatureRepo: sigRepo,
      );

      expect(result, isA<VoidFailure>());
      expect(sigRepo.saves, isEmpty);
    });

    test('signing data not found — returns Failure', () async {
      final openIdentity = OpenIdentity(
        id: 'i1',
        privateKey: _testKeyPair.privateKey,
      );

      final service = EintragSigningService(
        identityOpener: _IdentityOpenerStub(openIdentity),
        signingDataSource: _SigningDataStub(null),
      );
      final sigRepo = _SavingSignatureStub('e1');

      final result = await service.sign(
        eintragId: 'e1',
        identityId: 'i1',
        password: 'test-password',
        signatureRepo: sigRepo,
      );

      expect(result, isA<VoidFailure>());
      expect(sigRepo.saves, isEmpty);
    });

    test(
      'PasswortWrongException from openIdentity — returns Failure',
      () async {
        final service = EintragSigningService(
          identityOpener: _FailingIdentityOpenerStub(
            crypto.PasswortWrongException(),
          ),
          signingDataSource: _SigningDataStub('signing data string'),
        );
        final sigRepo = _SavingSignatureStub('e1');

        final result = await service.sign(
          eintragId: 'e1',
          identityId: 'i1',
          password: 'wrong-password',
          signatureRepo: sigRepo,
        );

        expect(result, isA<VoidFailure>());
        expect(sigRepo.saves, isEmpty);
      },
    );

    test(
      'CorruptedKeyContainerException from openIdentity — returns Failure',
      () async {
        final service = EintragSigningService(
          identityOpener: _FailingIdentityOpenerStub(
            crypto.CorruptedKeyContainerException(),
          ),
          signingDataSource: _SigningDataStub('signing data string'),
        );
        final sigRepo = _SavingSignatureStub('e1');

        final result = await service.sign(
          eintragId: 'e1',
          identityId: 'i1',
          password: 'test-password',
          signatureRepo: sigRepo,
        );

        expect(result, isA<VoidFailure>());
        expect(sigRepo.saves, isEmpty);
      },
    );

    test(
      'PrivateKeyNotFoundException from openIdentity — returns Failure',
      () async {
        final service = EintragSigningService(
          identityOpener: _FailingIdentityOpenerStub(
            PrivateKeyNotFoundException(),
          ),
          signingDataSource: _SigningDataStub('signing data string'),
        );
        final sigRepo = _SavingSignatureStub('e1');

        final result = await service.sign(
          eintragId: 'e1',
          identityId: 'i1',
          password: 'test-password',
          signatureRepo: sigRepo,
        );

        expect(result, isA<VoidFailure>());
        expect(sigRepo.saves, isEmpty);
      },
    );
  });
}
