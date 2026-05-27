import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../assembly/eintrag_assembly.dart';
import '../../repository/signature/signature_repository.dart';
import '../../service/eintrag_signing_service.dart';

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
    assert(state.hasValue);
    return Result.voidSafeAsync(() async {
      final service = ref.read(eintragSigningServiceProvider);
      final signatureRepo = ref.read(
        signatureRepositoryProvider(state.asData!.value.id),
      );
      await service
          .sign(
            eintragId: state.asData!.value.id,
            identityId: identityId,
            password: password,
            signatureRepo: signatureRepo,
          )
          .unwrap();
      ref.invalidateSelf();
    });
  }
}
