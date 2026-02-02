import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jldb/jldb.dart';

part 'eintrag_model.freezed.dart';

@freezed
abstract class Eintrag with _$Eintrag {
  const factory Eintrag({
    required String id,
    required DateTime start,
    required DateTime end,
    required String kategorieId,
    required String thema,
    String? ort,
    String? raum,
    String? dienstverlauf,
    String? besonderheiten,
    required Set<String> betreuerIds,
    required Set<String> anwesendeJugendlicherIds,
    required Set<String> entschuldigteJugendlicherIds,
  }) = _Eintrag;

  static Eintrag fromApiModel(EintragApiModel model) {
    return Eintrag(
      id: model.id.toString(),
      start: model.start,
      end: model.end,
      kategorieId: model.kategorieId.toString(),
      thema: model.thema,
      ort: model.ort,
      raum: model.raum,
      dienstverlauf: model.dienstverlauf,
      besonderheiten: model.besonderheiten,
      betreuerIds: model.betreuerIds.map((e) => e.toString()).toSet(),
      anwesendeJugendlicherIds: model.anwesendeJugendlicherIds
          .map((e) => e.toString())
          .toSet(),
      entschuldigteJugendlicherIds: model.entschuldigteJugendlicherIds
          .map((e) => e.toString())
          .toSet(),
    );
  }
}
