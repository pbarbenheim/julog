import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncResult;
import 'package:jlcrypto/jlcrypto.dart' as crypto;
import 'package:jldb/jldb.dart';

import '../../provider/jldb/jldb.dart';
import '../../provider/jldb/julog_file.dart';
import '../model/model.dart';
import '../repository_base.dart';

typedef SignatureCreateData = ({
  String identityId,
  crypto.Signature signature,
  DateTime timestamp,
  int version,
});

class _SignatureRepository
    extends JulogRepository<Signature, SignatureApiModel, SignatureCreateData> {
  final Jldb _jldb;
  final String _eintragId;

  _SignatureRepository({required Jldb jldb, required String eintragId})
    : _jldb = jldb,
      _eintragId = eintragId;

  @override
  AsyncResult<Signature> createInJldb(SignatureCreateData data) {
    return asyncResultFromFunction(() async {
      final signature = await _jldb
          .createSignature(
            SignatureApiModel(
              eintragId: UUID.fromString(_eintragId),
              identityId: UUID.fromString(data.identityId),
              signature: data.signature.toString(),
              timestamp: data.timestamp,
              version: data.version,
            ),
          )
          .getOrThrow();
      final isValid = await _isSignatureValid(
        '${signature.eintragId}:${signature.identityId}',
      ).getOrThrow();
      return Signature.fromApiModel(signature, isValid);
    });
  }

  AsyncResult<bool> _isSignatureValid(String id) {
    return asyncResultFromFunction(() async {
      final signatures = await _jldb
          .getSignaturesByEintragId(UUID.fromString(_eintragId))
          .getOrThrow();
      final signature = signatures.firstWhere(
        (s) => '${s.eintragId}:${s.identityId}' == id,
      );
      final eintragId = signature.eintragId;
      final identityId = signature.identityId;
      final cryptoSignature = signature.signature;

      final eintragResult =
          (await _jldb
                  .getEintragForSigning(
                    eintragId,
                    signature.version,
                    signature.timestamp,
                  )
                  .getOrThrow())
              .unwrap();
      final identity = (await _jldb.getIdentity(identityId).getOrThrow())
          .unwrap();
      final publicKey = crypto.PublicKey.fromString(identity.publicKey);
      final isValid = await compute(
        ((crypto.PublicKey, String, crypto.Signature) data) => data.$1
            .verifySHA512Signature(crypto.Message.fromString(data.$2), data.$3),
        (
          publicKey,
          eintragResult,
          crypto.Signature.fromString(cryptoSignature),
        ),
      );
      return isValid;
    });
  }

  @override
  AsyncResult<List<SignatureApiModel>> fetchAllFromJldb() =>
      _jldb.getSignaturesByEintragId(UUID.fromString(_eintragId));

  @override
  Future<Signature> fromJldbRecord(SignatureApiModel record) async {
    final isValid = await _isSignatureValid(
      '${record.eintragId}:${record.identityId}',
    ).getOrThrow();
    return Signature.fromApiModel(record, isValid);
  }

  @override
  String getId(Signature item) => item.id;
}

// Unfortunately, we cant use code generation here due to an issue in riverpod with complex return types
final signatureRepositoryProvider = Provider.autoDispose
    .family<
      JulogRepository<Signature, SignatureApiModel, SignatureCreateData>,
      String
    >((ref, eintragId) {
      final jldb = ref.watch(julogServiceProvider);
      if (jldb is! JulogFileLoaded) {
        throw StateError('Julog file is not loaded');
      }
      return _SignatureRepository(jldb: jldb.jldb, eintragId: eintragId);
    });
