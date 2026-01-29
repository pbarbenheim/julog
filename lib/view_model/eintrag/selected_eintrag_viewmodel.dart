import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jlcrypto/jlcrypto.dart' as crypto;
import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repository/betreuer/repository.dart';
import '../../repository/eintrag/eintrag_repo.dart';
import '../../repository/identity/repository.dart';
import '../../repository/jugendliche/repository.dart';
import '../../repository/kategorie/repository.dart';
import '../../repository/model/model.dart';
import '../../repository/signature/signature_repository.dart';

part 'selected_eintrag_viewmodel.g.dart';
part 'selected_eintrag_viewmodel.freezed.dart';

@riverpod
class SelectedEintragViewModel extends _$SelectedEintragViewModel {
  @override
  Future<SelectedEintrag> build(String id) async {
    final eintragRepo = ref.watch(eintragRepositoryProvider);
    final kategorieRepo = ref.watch(kategorieRepositoryProvider);
    final signatureRepo = ref.watch(signatureRepositoryProvider(id));
    final jugendlicheRepo = ref.watch(jugendlicheRepositoryProvider);
    final betreuerRepo = ref.watch(betreuerRepositoryProvider);
    final identityRepo = ref.watch(identityRepositoryProvider);

    final eintrag = (await eintragRepo.getById(id).getOrThrow()).unwrap();
    final kategorie =
        (await kategorieRepo.getById(eintrag.kategorieId).getOrThrow())
            .unwrap();
    final signatures = await signatureRepo.getAll().getOrThrow();
    final betreuerList = await Future.wait(
      eintrag.betreuerIds.map((id) async {
        return (await betreuerRepo.getById(id).getOrThrow()).unwrap();
      }),
    );
    final anwesendeJugendlicheList = await Future.wait(
      eintrag.anwesendeJugendlicherIds.map((id) async {
        return (await jugendlicheRepo.getById(id).getOrThrow()).unwrap();
      }),
    );
    final entschuldigteJugendlicheList = await Future.wait(
      eintrag.entschuldigteJugendlicherIds.map((id) async {
        return (await jugendlicheRepo.getById(id).getOrThrow()).unwrap();
      }),
    );

    final possibleSigners = await identityRepo.getAll().getOrThrow();

    return SelectedEintrag(
      id: eintrag.id,
      start: eintrag.start,
      end: eintrag.end,
      kategorie: kategorie,
      thema: eintrag.thema,
      ort: eintrag.ort,
      raum: eintrag.raum,
      dienstverlauf: eintrag.dienstverlauf,
      besonderheiten: eintrag.besonderheiten,
      betreuer: betreuerList,
      anwesendeJugendliche: anwesendeJugendlicheList,
      entschuldigteJugendliche: entschuldigteJugendlicheList,
      signatures: signatures,
      possibleSigners: possibleSigners,
    );
  }

  AsyncVoidResult sign(String identityId, String password) async {
    const currentVersion = 4;
    assert(state.hasValue);
    final timestamp = DateTime.timestamp();

    final identityRepo = ref.read(identityRepositoryProvider);
    final eintragRepo = ref.read(eintragRepositoryProvider);
    final signatureRepo = ref.read(
      signatureRepositoryProvider(state.asData!.value.id),
    );

    final identity = await identityRepo.openIdentity(identityId, password);
    if (identity.isFailure()) {
      return Failure(identity.getFailureOptional().unwrap());
    }

    final eintragResult = await eintragRepo.getEintragSigningData(
      state.asData!.value.id,
      currentVersion,
      timestamp,
    );
    if (eintragResult.isFailure()) {
      return Failure(eintragResult.getFailureOptional().unwrap());
    }
    final eintragString = eintragResult.getOrThrow().unwrap();

    final privateKey = identity.getOrThrow().unwrap().privateKey;
    final crypto.Signature signature;
    try {
      signature = await compute(
        ((crypto.PrivateKey, String) data) =>
            data.$1.signSHA512(crypto.Message.fromString(data.$2)),
        (privateKey, eintragString),
      );
    } on Exception catch (e) {
      return Failure(e);
    }

    await signatureRepo.save((
      identityId: identityId,
      signature: signature,
      timestamp: timestamp,
      version: currentVersion,
    ));

    ref.invalidateSelf();
    return asyncVoidResult();
  }
}

@freezed
abstract class SelectedEintrag with _$SelectedEintrag {
  const factory SelectedEintrag({
    required String id,
    required DateTime start,
    required DateTime end,
    required Kategorie kategorie,
    String? thema,
    String? ort,
    String? raum,
    String? dienstverlauf,
    String? besonderheiten,
    required List<Betreuer> betreuer,
    required List<Jugendlicher> anwesendeJugendliche,
    required List<Jugendlicher> entschuldigteJugendliche,
    required List<Signature> signatures,
    required List<Identity> possibleSigners,
  }) = _SelectedEintrag;
}
