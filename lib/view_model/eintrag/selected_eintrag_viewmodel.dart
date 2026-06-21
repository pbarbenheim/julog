import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../assembly/eintrag_assembly.dart';
import '../../repository/eintrag/eintrag_repo.dart';
import '../../repository/signature/signature_repository.dart';
import '../../service/eintrag_signing_service.dart';
import 'eintrag_viewmodel.dart';

part 'selected_eintrag_viewmodel.g.dart';

@riverpod
class SelectedEintragViewModel extends _$SelectedEintragViewModel {
  @override
  Future<SelectedEintrag> build(String id) async {
    final assembly = ref.watch(eintragAssemblyProvider);
    final signatureRepo = ref.watch(signatureRepositoryProvider(id));
    return (await assembly.assemble(id, signatureRepo)).unwrap();
  }

  AsyncVoidResult delete() {
    assert(state.hasValue);
    return Result.voidSafeAsync(() async {
      final repo = ref.read(eintragRepositoryProvider);
      await repo.delete(state.asData!.value.id).unwrap();
      ref.invalidate(eintragViewModelProvider);
    });
  }

  AsyncVoidResult editEintrag({
    required DateTime start,
    required DateTime end,
    required String kategorieId,
    required String thema,
    String? ort,
    String? raum,
    String? dienstverlauf,
    String? besonderheiten,
    required List<String> betreuerIds,
    required List<String> anwesendeJugendlicherIds,
    required List<String> entschuldigteJugendlicherIds,
  }) {
    assert(state.hasValue);
    return Result.voidSafeAsync(() async {
      final repo = ref.read(eintragRepositoryProvider);
      await repo.update((
        id: state.asData!.value.id,
        start: start,
        end: end,
        kategorieId: kategorieId,
        thema: thema,
        ort: ort,
        raum: raum,
        dienstverlauf: dienstverlauf,
        besonderheiten: besonderheiten,
        betreuerIds: betreuerIds,
        anwesendeJugendlicherIds: anwesendeJugendlicherIds,
        entschuldigteJugendlicherIds: entschuldigteJugendlicherIds,
      )).unwrap();
      ref.invalidate(eintragViewModelProvider);
      ref.invalidateSelf();
    });
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
