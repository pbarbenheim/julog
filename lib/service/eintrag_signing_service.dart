import 'package:flutter/foundation.dart';
import 'package:jlcrypto/jlcrypto.dart' as crypto;
import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../repository/eintrag/eintrag_repo.dart';
import '../repository/identity/repository.dart';
import '../repository/model/model.dart';
import '../repository/repository_base.dart';
import '../repository/signature/signature_repository.dart';

part 'eintrag_signing_service.g.dart';

abstract interface class IdentityOpener {
  AsyncResultOptional<OpenIdentity> openIdentity(String id, String password);
}

abstract interface class EintragSigningDataSource {
  AsyncResult<Optional<String>> getEintragSigningData(
    String eintragId,
    int version,
    DateTime timestamp,
  );
}

class EintragSigningService {
  final IdentityOpener _identityOpener;
  final EintragSigningDataSource _signingDataSource;

  const EintragSigningService({
    required IdentityOpener identityOpener,
    required EintragSigningDataSource signingDataSource,
  })  : _identityOpener = identityOpener,
        _signingDataSource = signingDataSource;

  AsyncVoidResult sign({
    required String eintragId,
    required String identityId,
    required String password,
    required JulogRepository<Signature, SignatureApiModel, SignatureCreateData>
        signatureRepo,
  }) {
    const currentVersion = 5;
    return Result.voidSafeAsync(() async {
      final timestamp = DateTime.timestamp();

      final identityOpt =
          await _identityOpener.openIdentity(identityId, password).unwrap();
      if (identityOpt is None<OpenIdentity>) {
        throw Exception('Identity not found: $identityId');
      }
      final identity = identityOpt.unwrap();

      final signingDataOpt = await _signingDataSource
          .getEintragSigningData(eintragId, currentVersion, timestamp)
          .unwrap();
      if (signingDataOpt is None<String>) {
        throw Exception('Signing data not found for eintrag: $eintragId');
      }
      final signingData = signingDataOpt.unwrap();

      final signature = await compute(
        ((crypto.PrivateKey, String) data) =>
            data.$1.signSHA512(crypto.Message.fromString(data.$2)),
        (identity.privateKey, signingData),
      );

      await signatureRepo.save((
        identityId: identityId,
        signature: signature,
        timestamp: timestamp,
        version: currentVersion,
      ));
    });
  }
}

@riverpod
EintragSigningService eintragSigningService(Ref ref) => EintragSigningService(
      identityOpener: ref.watch(identityRepositoryProvider),
      signingDataSource: ref.watch(eintragRepositoryProvider),
    );
