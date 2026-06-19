import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jlcrypto/jlcrypto.dart' as crypto;
import 'package:jldb/jldb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;

import '../repository/betreuer/repository.dart';
import '../repository/repository_base.dart';
import '../repository/eintrag/eintrag_repo.dart';
import '../repository/identity/repository.dart';
import '../repository/jugendliche/repository.dart';
import '../repository/kategorie/repository.dart';
import '../repository/model/model.dart';
import '../repository/signature/signature_repository.dart';

part 'eintrag_assembly.g.dart';
part 'eintrag_assembly.freezed.dart';

class EintragAssembly {
  final JulogRepository<Eintrag, EintragApiModel, EintragCreateData>
  _eintragRepo;
  final JulogRepository<Kategorie, KategorieApiModel, KategorieCreate>
  _kategorieRepo;
  final JulogRepository<
    Jugendlicher,
    JugendlicherApiModel,
    JugendlicheCreateData
  >
  _jugendlicheRepo;
  final JulogRepository<
    Betreuer,
    BetreuerApiModel,
    ({String name, Gender gender})
  >
  _betreuerRepo;
  final JulogRepository<Identity, IdentityApiModel, IdentityCreateData>
  _identityRepo;

  const EintragAssembly({
    required JulogRepository<Eintrag, EintragApiModel, EintragCreateData>
    eintragRepo,
    required JulogRepository<Kategorie, KategorieApiModel, KategorieCreate>
    kategorieRepo,
    required JulogRepository<
      Jugendlicher,
      JugendlicherApiModel,
      JugendlicheCreateData
    >
    jugendlicheRepo,
    required JulogRepository<
      Betreuer,
      BetreuerApiModel,
      ({String name, Gender gender})
    >
    betreuerRepo,
    required JulogRepository<Identity, IdentityApiModel, IdentityCreateData>
    identityRepo,
  }) : _eintragRepo = eintragRepo,
       _kategorieRepo = kategorieRepo,
       _jugendlicheRepo = jugendlicheRepo,
       _betreuerRepo = betreuerRepo,
       _identityRepo = identityRepo;

  AsyncResult<SelectedEintrag> assemble(
    String eintragId,
    JulogRepository<Signature, SignatureApiModel, SignatureCreateData>
    signatureRepo,
  ) {
    return Result.safeAsync(() async {
      final eintragOpt = await _eintragRepo.getById(eintragId).unwrap();
      if (eintragOpt is None<Eintrag>) {
        throw Exception('Eintrag not found: $eintragId');
      }
      final eintrag = eintragOpt.unwrap();

      final kategorieOpt = await _kategorieRepo
          .getById(eintrag.kategorieId)
          .unwrap();
      if (kategorieOpt is None<Kategorie>) {
        throw Exception('Kategorie not found: ${eintrag.kategorieId}');
      }
      final kategorie = kategorieOpt.unwrap();

      final signatures = await signatureRepo
          .getAll()
          .mapIterable((signature) async {
            final identity = await _identityRepo
                .getById(signature.identityId)
                .unwrapAll();
            return ShowingSignature.fromSignature(
              signature: signature,
              identity: identity,
            );
          })
          .map((list) => Future.wait(list))
          .unwrap();

      Future<Betreuer> resolveBetreuer(String id) async {
        final opt = await _betreuerRepo.getById(id).unwrap();
        if (opt is None<Betreuer>) throw Exception('Betreuer not found: $id');
        return opt.unwrap();
      }

      Future<Jugendlicher> resolveJugendlicher(String id) async {
        final opt = await _jugendlicheRepo.getById(id).unwrap();
        if (opt is None<Jugendlicher>) {
          throw Exception('Jugendlicher not found: $id');
        }
        return opt.unwrap();
      }

      final betreuerList = await Future.wait(
        eintrag.betreuerIds.map(resolveBetreuer),
      );
      final anwesendeJugendlicheList = await Future.wait(
        eintrag.anwesendeJugendlicherIds.map(resolveJugendlicher),
      );
      final entschuldigteJugendlicheList = await Future.wait(
        eintrag.entschuldigteJugendlicherIds.map(resolveJugendlicher),
      );
      final undefinierteJugendlicheList = await Future.wait(
        eintrag.undefinierteJugendlicherIds.map(resolveJugendlicher),
      );

      final possibleSigners = await _identityRepo.getAll().unwrap();

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
        undefinierteJugendliche: undefinierteJugendlicheList,
        signatures: signatures,
        possibleSigners: possibleSigners,
      );
    });
  }
}

@riverpod
EintragAssembly eintragAssembly(Ref ref) {
  return EintragAssembly(
    eintragRepo: ref.watch(eintragRepositoryProvider),
    kategorieRepo: ref.watch(kategorieRepositoryProvider),
    jugendlicheRepo: ref.watch(jugendlicheRepositoryProvider),
    betreuerRepo: ref.watch(betreuerRepositoryProvider),
    identityRepo: ref.watch(identityRepositoryProvider),
  );
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
    required List<Jugendlicher> undefinierteJugendliche,
    required List<ShowingSignature> signatures,
    required List<Identity> possibleSigners,
  }) = _SelectedEintrag;
}

@freezed
abstract class ShowingSignature with _$ShowingSignature {
  const ShowingSignature._();
  const factory ShowingSignature({
    required String id,
    required String eintragId,
    required Identity identity,
    required crypto.Signature signature,
    required DateTime timestamp,
    required bool isValid,
  }) = _ShowingSignature;

  factory ShowingSignature.fromSignature({
    required Signature signature,
    required Identity identity,
  }) => ShowingSignature(
    eintragId: signature.eintragId,
    id: signature.id,
    identity: identity,
    signature: signature.signature,
    timestamp: signature.timestamp,
    isValid: signature.isValid,
  );
}
