import 'package:flutter/foundation.dart';
import 'package:jlcrypto/jlcrypto.dart' as crypto;
import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../assembly/eintrag_assembly.dart';
import '../../repository/eintrag/eintrag_repo.dart';
import '../../repository/identity/repository.dart';
import '../../repository/signature/signature_repository.dart';

part 'selected_eintrag_viewmodel.g.dart';

@riverpod
class SelectedEintragViewModel extends _$SelectedEintragViewModel {
  @override
  Future<SelectedEintrag> build(String id) async {
    final assembly = ref.watch(eintragAssemblyProvider);
    final signatureRepo = ref.watch(signatureRepositoryProvider(id));
    return (await assembly.assemble(id, signatureRepo)).unwrap();
  }

  AsyncVoidResult sign(String identityId, String password) {
    const currentVersion = 4;
    assert(state.hasValue);
    final timestamp = DateTime.timestamp();

    return Result.voidSafeAsync(() async {
      final identityRepo = ref.read(identityRepositoryProvider);
      final eintragRepo = ref.read(eintragRepositoryProvider);
      final signatureRepo = ref.read(
        signatureRepositoryProvider(state.asData!.value.id),
      );

      final identity = await identityRepo
          .openIdentity(identityId, password)
          .unwrapAll();

      final eintragString = await eintragRepo
          .getEintragSigningData(
            state.asData!.value.id,
            currentVersion,
            timestamp,
          )
          .unwrapAll();

      final privateKey = identity.privateKey;
      final crypto.Signature signature;

      signature = await compute(
        ((crypto.PrivateKey, String) data) =>
            data.$1.signSHA512(crypto.Message.fromString(data.$2)),
        (privateKey, eintragString),
      );

      await signatureRepo.save((
        identityId: identityId,
        signature: signature,
        timestamp: timestamp,
        version: currentVersion,
      ));

      ref.invalidateSelf();
    });
  }
}
